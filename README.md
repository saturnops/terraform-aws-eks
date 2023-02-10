# AWS EKS Terraform module


<br>
This terraform module is used to create EKS cluster and related resources for container workload deployment on AWS Cloud.


## Usage Example

```hcl
module "eks" {
  source = "saturnops/eks/aws"
    name = "SKAF"
    environment = "production"  
    cluster_enabled_log_types = ["api","scheduler"]
    cluster_version = "1.23"
    cluster_log_retention_in_days = 30
    cluster_endpoint_public_access = true
    cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
    vpc_id = "vpc-06e37f0786b7eskaf"
    private_subnet_ids    = ["subnet-00exyzd5df967d21w","subnet-0c4abcd5aedxyzaea"]
    kms_key_arn           = "arn:aws:kms:us-east-2:222222222222:key/kms_key_arn"
    kms_policy_arn        = "arn:aws:iam::222222222222:policy/kms_policy_arn"
}

module "managed_node_group_production" {
    source = "saturnops/eks/aws//node-groups/managed-nodegroup"
    name                  = "SKAF"
    environment           = "production"
    eks_cluster_id        = "production-cluster"
    eks_nodes_keypair     = "prod-key"
    subnet_ids            = ["subnet-00exyzd5df967d21w"]
    worker_iam_role_arn   = "arn:aws:iam::222222222222:role/worker_iam_role_arn"
    worker_iam_role_name  = "worker_iam_role_name"
    kms_key_arn           = "arn:aws:kms:us-east-2:222222222222:key/kms_key_arn"
    kms_policy_arn        = "arn:aws:iam::222222222222:policy/kms_policy_arn"
    desired_size          = 1
    max_size              = 3
    instance_types        = ["t3a.xlarge"]
    capacity_type         = "ON_DEMAND"
    k8s_labels = {
      "Infra-Services" = "true"
    }
}

```
Refer [examples](https://github.com/saturnops/terraform-aws-eks/tree/main/examples/complete) for more details.
## IAM Permissions
The required IAM permissions to create resources from this module can be found [here](https://github.com/saturnops/terraform-aws-eks/blob/main/IAM.md)

## Secure Configuration


| Benchmark | Description |
|--------|---------------|
| Ensure EKS Control Plane Audit Logging is enabled for all log types | Control plane logging enabled and correctly configured for EKS cluster |
| Ensure Kubernetes Secrets are encrypted using Customer Master Keys (CMKs) | Encryption for Kubernetes secrets is configured for EKS cluster |
| Ensure EKS Clusters are created with Private Endpoint Enabled and Public Access Disabled | Cluster endpoint access is private for EKS cluster  |
| Restrict Access to the EKS Control Plane Endpoint | Cluster control plane access is restricted for EKS cluster |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.23 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.13 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.23 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 18.29.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_kms_cluster_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logs to enable for EKS cluster. Valid values: api,audit,authenticator,controllerManager,scheduler | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Retention period for EKS cluster logs | `number` | `90` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes <major>.<minor> version to use for the EKS cluster | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment identifier for the EKS cluster | `string` | `""` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key to Encrypt EKS resources. | `string` | `""` | no |
| <a name="input_kms_policy_arn"></a> [kms\_policy\_arn](#input\_kms\_policy\_arn) | KMS policy to Encrypt/Decrypt EKS resources. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Specify the name of the EKS cluster | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets of the VPC which can be used by EKS | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the EKS cluster | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and its nodes will be provisioned | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | The URL on the EKS cluster for the OpenID Connect identity provider |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane |
| <a name="output_kubeconfig_context_name"></a> [kubeconfig\_context\_name](#output\_kubeconfig\_context\_name) | Name of the kubeconfig context |
| <a name="output_region"></a> [region](#output\_region) | AWS Region for the EKS cluster |
| <a name="output_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#output\_worker\_iam\_role\_arn) | ARN of the EKS Worker Role |
| <a name="output_worker_iam_role_name"></a> [worker\_iam\_role\_name](#output\_worker\_iam\_role\_name) | The name of the EKS Worker IAM role |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->






##        





Please give our GitHub repository a ⭐️ to show your support and increase its visibility.






