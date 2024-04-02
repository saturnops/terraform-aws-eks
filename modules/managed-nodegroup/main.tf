data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_region" "current" {}

data "aws_ami" "launch_template_ami" {
  owners      = ["602401143452"]
  most_recent = true
  filter {
    name   = "name"
    values = [format("%s-%s-%s", "amazon-eks-node", data.aws_eks_cluster.eks.version, "v*")]
  }
}

data "template_file" "launch_template_userdata" {
  count    = var.aws_managed_node_group_amd64 ? 1 : 0
  template = file("${path.module}/templates/${data.aws_eks_cluster.eks.kubernetes_network_config[0].ip_family == "ipv4" ? "custom-bootstrap-script.sh.tpl" : "custom-bootstrap-scriptipv6.sh.tpl"}")

  vars = {
    endpoint                     = data.aws_eks_cluster.eks.endpoint
    cluster_name                 = var.eks_cluster_name
    eventRecordQPS               = var.eventRecordQPS
    cluster_auth_base64          = data.aws_eks_cluster.eks.certificate_authority[0].data
    image_low_threshold_percent  = var.image_low_threshold_percent
    image_high_threshold_percent = var.image_high_threshold_percent
    managed_ng_pod_capacity      = var.managed_ng_pod_capacity

  }
}

resource "aws_launch_template" "eks_template" {
  count                  = var.aws_managed_node_group_amd64 ? 1 : 0
  name                   = format("%s-%s-%s", var.environment, var.name, "launch-template")
  key_name               = var.eks_nodes_keypair_name
  image_id               = data.aws_ami.launch_template_ami.image_id
  user_data              = base64encode(data.template_file.launch_template_userdata[0].rendered)
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      delete_on_termination = true
      encrypted             = var.ebs_encrypted
      kms_key_id            = var.kms_key_arn
    }
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = true
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = format("%s-%s-%s", var.environment, var.name, "eks-node")
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "managed_ng" {
  count           = var.aws_managed_node_group_amd64 ? 1 : 0
  subnet_ids      = var.subnet_ids
  cluster_name    = var.eks_cluster_name
  node_role_arn   = var.worker_iam_role_arn
  node_group_name = format("%s-%s-%s", var.environment, var.name, "ng")
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }
  labels               = var.k8s_labels
  capacity_type        = var.capacity_type
  instance_types       = var.instance_types
  force_update_version = true
  launch_template {
    id      = aws_launch_template.eks_template[0].id
    version = aws_launch_template.eks_template[0].latest_version
  }
  update_config {
    max_unavailable_percentage = 50
  }
  tags = {
    Name        = format("%s-%s-%s", var.environment, var.name, "ng")
    Environment = var.environment
  }
}

resource "aws_eks_addon" "vpc_cni" {
  depends_on   = [aws_eks_node_group.managed_ng]
  count        = var.aws_managed_node_group_amd64 ? 1 : 0
  cluster_name = var.eks_cluster_name
  addon_name   = "vpc-cni"
}

resource "null_resource" "update_vpc_cni_env_var" {
  count      = var.aws_managed_node_group_amd64 ? 1 : 0
  depends_on = [aws_eks_addon.vpc_cni, aws_eks_node_group.managed_ng]

  provisioner "local-exec" {
    command = <<-EOF
      aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${data.aws_region.current.name} &&
      kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true &&
      kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1 &&
      kubectl set env daemonset aws-node -n kube-system WARM_ENI_TARGET=1
    EOF
  }
}
