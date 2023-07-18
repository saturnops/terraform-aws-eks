# AWS EKS Terraform module


<br>
This module simplifies the deployment of EKS clusters with dual stack mode for Cluster IP family like IPv6 and IPv4, allowing users to quickly create and manage a production-grade Kubernetes cluster on AWS. The module is highly configurable, allowing users to customize various aspects of the EKS cluster, such as the Kubernetes version, worker node instance type, number of worker nodes, and now with added support for EKS version 1.26.
<br>


## Usage Example

```hcl
module "eks" {
  source                               = "saturnops/eks/aws"
  name                                 = "SKAF"
  vpc_id                               = module.vpc.vpc_id
  environment                          = "production"
  ipv6_enabled                         = true
  kms_key_arn                          = "arn:aws:kms:us-east-2:222222222222:key/kms_key_arn"
  create_aws_auth_configmap            = true
  aws_auth_users                       = []
  aws_auth_roles                       = []
  additional_rules                     = {}
  cluster_version                      = "1.26"
  cluster_log_types                    = ["api", "scheduler"]
  private_subnet_ids                   = ["subnet-00exyzf967d21w","subnet-00exyzd967sqop"]
  cluster_log_retention_in_days        = 30
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
  
}

module "managed_node_group_production" {
  source                 = "saturnops/eks/aws//modules/managed-nodegroup"
  depends_on             = [module.eks]
  name                   = "Infra"
  min_size               = 1
  max_size               = 3
  desired_size           = 1
  subnet_ids             = ["subnet-00exyzd5df967d21w"]
  environment            = "production"
  ipv6_enabled           = true
  kms_key_arn            = "arn:aws:kms:us-east-2:222222222222:key/kms_key_arn"
  capacity_type          = "ON_DEMAND"
  instance_types         = ["t3a.large", "t2.large"]
  kms_policy_arn         = "kms_policy_arn"
  eks_cluster_name       = "production-cluster"
  worker_iam_role_name   = "arn:aws:iam::222222222222:role/worker_iam_role_arn"
  eks_nodes_keypair_name = "prod-key"
  k8s_labels = {
    "Infra-Services" = "true"
  }
  tags = local.additional_aws_tags
}

```
Refer [examples](https://github.com/saturnops/terraform-aws-eks/tree/main/examples/complete) for more details.

## IAM Permissions
The required IAM permissions to create resources from this module can be found [here](https://github.com/saturnops/terraform-aws-eks/blob/main/IAM.md)

## EKS-BOOTSTRAP


## Secure Configuration


In this module, we have implemented the followingchecks for EKS:

| Benchmark | Description | Status |
|--------|---------------|----------|
| Ensure EKS Control Plane Audit Logging is enabled for all log types | Control plane logging enabled and correctly configured for EKS cluster | &#x2714; |
| Ensure Kubernetes Secrets are encrypted using Customer Master Keys (CMKs) | Encryption for Kubernetes secrets is configured for EKS cluster | &#x2714; |
| Ensure EKS Clusters are created with Private Endpoint Enabled and Public Access Disabled | Cluster endpoint access is private for EKS cluster  | &#x2714; |
| Restrict Access to the EKS Control Plane Endpoint | Cluster control plane access is restricted for EKS cluster | &#x2714; |


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.15.2 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.kubernetes_pvc_kms_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.node_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eks_kms_cluster_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment identifier for the EKS cluster, such as dev, qa, prod, etc. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Specify the name of the EKS cluster. | `string` | `""` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Specifies the Kubernetes version (major.minor) to use for the EKS cluster. | `string` | `""` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Whether the Amazon EKS public API server endpoint is enabled or not. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | CIDR blocks that can access the Amazon EKS public API server endpoint. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the EKS cluster will be deployed. | `string` | `""` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of the KMS key used to encrypt EKS resources. | `string` | `""` | no |
| <a name="input_cluster_log_types"></a> [cluster\_log\_types](#input\_cluster\_log\_types) | A list of desired control plane logs to enable for the EKS cluster. Valid values include: api, audit, authenticator, controllerManager, scheduler. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Retention period for EKS cluster logs in days. Default is set to 90 days. | `number` | `90` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnets of the VPC which can be used by EKS | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Controls if a KMS key for cluster encryption should be created | `bool` | `false` | no |
| <a name="input_additional_rules"></a> [additional\_rules](#input\_additional\_rules) | List of additional security group rules to add to the cluster security group created. | `any` | `{}` | no |
| <a name="input_create_aws_auth_configmap"></a> [create\_aws\_auth\_configmap](#input\_create\_aws\_auth\_configmap) | Determines whether to manage the aws-auth configmap | `bool` | `false` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | List of user maps to add to the aws-auth configmap | `any` | `[]` | no |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | List of role maps to add to the aws-auth configmap | `list(any)` | `[]` | no |
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | Enable cluster IP family as Ipv6 | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of the Kubernetes cluster. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint URL for the EKS control plane. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group IDs that are attached to the control plane of the EKS cluster. |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the EKS Cluster. |
| <a name="output_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#output\_cluster\_oidc\_issuer\_url) | URL of the OpenID Connect identity provider on the EKS cluster. |
| <a name="output_worker_iam_role_arn"></a> [worker\_iam\_role\_arn](#output\_worker\_iam\_role\_arn) | ARN of the IAM role assigned to the EKS worker nodes. |
| <a name="output_worker_iam_role_name"></a> [worker\_iam\_role\_name](#output\_worker\_iam\_role\_name) | Name of the IAM role assigned to the EKS worker nodes. |
| <a name="output_kms_policy_arn"></a> [kms\_policy\_arn](#output\_kms\_policy\_arn) | ARN of the KMS policy that is used by the EKS cluster. |
| <a name="output_cluster_certificate_authority_data"></a> [cluster\_certificate\_authority\_data](#output\_cluster\_certificate\_authority\_data) | Base64 encoded certificate data required to communicate with the cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->






##        





Please give our GitHub repository a ⭐️ to show your support and increase its visibility.





