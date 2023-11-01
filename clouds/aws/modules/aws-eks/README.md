# aws-eks

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_kms_key"></a> [ebs\_kms\_key](#module\_ebs\_kms\_key) | terraform-aws-modules/kms/aws | 1.5.0 |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | 1.2.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.15.3 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [null_resource.create_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_tf_bp_version"></a> [aws\_tf\_bp\_version](#input\_aws\_tf\_bp\_version) | AWS Terraform Blueprint Version | `string` | `"v5"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability Zones to use for the EKS cluster. | `list(string)` | n/a | yes |
| <a name="input_enable_efs"></a> [enable\_efs](#input\_enable\_efs) | Enable EFS Storage for the EKS cluster. | `bool` | `true` | no |
| <a name="input_k8s_api_private"></a> [k8s\_api\_private](#input\_k8s\_api\_private) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_k8s_api_public"></a> [k8s\_api\_public](#input\_k8s\_api\_public) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_k8s_apps_node_size"></a> [k8s\_apps\_node\_size](#input\_k8s\_apps\_node\_size) | Desired number of nodes for the k8s-apps node group. Node group is not scalable. | `number` | `1` | no |
| <a name="input_k8s_instance_types"></a> [k8s\_instance\_types](#input\_k8s\_instance\_types) | Map with instance types to use for the EKS cluster nodes for each node group. See https://aws.amazon.com/ec2/instance-types/ | `map(list(string))` | <pre>{<br>  "agent": [<br>    "m5.2xlarge"<br>  ],<br>  "agent-spot": [<br>    "m5.2xlarge"<br>  ],<br>  "cb-apps": [<br>    "m5d.4xlarge"<br>  ],<br>  "k8s-apps": [<br>    "m5.8xlarge"<br>  ]<br>}</pre> | no |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version to use for the EKS cluster. Supported versions are 1.24. and 1.26 | `string` | `"1.26"` | no |
| <a name="input_kubeconfig_file_update"></a> [kubeconfig\_file\_update](#input\_kubeconfig\_file\_update) | Refresh kubeconfig file with the new EKS cluster configuration. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | EKS Name. | `string` | n/a | yes |
| <a name="input_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#input\_private\_subnets\_cidr\_blocks) | SSH CIDR blocks for existing Private Subnets. | `list(string)` | `[]` | no |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | Existing Private Subnet IDs. | `list(string)` | `[]` | no |
| <a name="input_s3_ci_backup_name"></a> [s3\_ci\_backup\_name](#input\_s3\_ci\_backup\_name) | S3 Bucket Name for CI Backups. | `string` | n/a | yes |
| <a name="input_ssh_cidr_blocks_k8s"></a> [ssh\_cidr\_blocks\_k8s](#input\_ssh\_cidr\_blocks\_k8s) | SSH CIDR blocks with access to the EKS cluster K8s API | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Existing VPC ID. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | EFS ID |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS cluster ID |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS cluster version |
| <a name="output_eks_oidc_provider"></a> [eks\_oidc\_provider](#output\_eks\_oidc\_provider) | EKS cluster OIDC issuer URL |
| <a name="output_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#output\_kubeconfig\_file\_path) | Kubeconfig full file path |
| <a name="output_kubeconfig_update"></a> [kubeconfig\_update](#output\_kubeconfig\_update) | Update KUBECONFIG file |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | EKS cluster node security group ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
