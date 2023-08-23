# eks-bp-v4-31

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.13.1 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | 4.3.2 |
| <a name="module_aws_s3_bucket"></a> [aws\_s3\_bucket](#module\_aws\_s3\_bucket) | ../../../modules/aws-s3-bucket | n/a |
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ../../../modules/aws-bastion | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | 1.2.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | 19.15.3 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [null_resource.create_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azs_number"></a> [azs\_number](#input\_azs\_number) | Number of Availability Zones to use for the VPC for the Selected Region. Minimum 2 for HA. | `number` | `3` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | An existing domain name maped to a Route 53 Hosted Zone | `string` | n/a | yes |
| <a name="input_enable_acm"></a> [enable\_acm](#input\_enable\_acm) | Enable ACM Certificate for the EKS cluster ingress. | `bool` | `true` | no |
| <a name="input_enable_bastion"></a> [enable\_bastion](#input\_enable\_bastion) | Enable Bastion Host for Private only EKS endpoints. | `bool` | `false` | no |
| <a name="input_enable_efs"></a> [enable\_efs](#input\_enable\_efs) | Enable EFS Storage for the EKS cluster. | `bool` | `true` | no |
| <a name="input_hosted_zone_type"></a> [hosted\_zone\_type](#input\_hosted\_zone\_type) | Route 53 Hosted Zone Type. | `string` | `"public"` | no |
| <a name="input_k8s_api_private"></a> [k8s\_api\_private](#input\_k8s\_api\_private) | Indicates whether or not the Amazon EKS private API server endpoint is enabled | `bool` | `false` | no |
| <a name="input_k8s_api_public"></a> [k8s\_api\_public](#input\_k8s\_api\_public) | Indicates whether or not the Amazon EKS public API server endpoint is enabled | `bool` | `true` | no |
| <a name="input_k8s_apps_node_size"></a> [k8s\_apps\_node\_size](#input\_k8s\_apps\_node\_size) | Desired number of nodes for the k8s-apps node group. Node group is not scalable. | `number` | `1` | no |
| <a name="input_k8s_instance_types"></a> [k8s\_instance\_types](#input\_k8s\_instance\_types) | Map with instance types to use for the EKS cluster nodes for each node group. See https://aws.amazon.com/ec2/instance-types/ | `map(list(string))` | <pre>{<br>  "agent": [<br>    "m5.2xlarge"<br>  ],<br>  "agent-spot": [<br>    "m5.2xlarge"<br>  ],<br>  "cb-apps": [<br>    "m5d.4xlarge"<br>  ],<br>  "k8s-apps": [<br>    "m5.8xlarge"<br>  ]<br>}</pre> | no |
| <a name="input_k8s_version"></a> [k8s\_version](#input\_k8s\_version) | Kubernetes version to use for the EKS cluster. Supported versions are 1.23 and 1.24. | `string` | `"1.24"` | no |
| <a name="input_key_name_bastion"></a> [key\_name\_bastion](#input\_key\_name\_bastion) | Name of the Existing Key Pair Name from EC2 to use for ssh into the Bastion Host instance. | `string` | `""` | no |
| <a name="input_preffix"></a> [preffix](#input\_preffix) | Preffix of the demo. Used for tagging and naming resources. Must be unique. | `string` | n/a | yes |
| <a name="input_private_subnets_cidr_blocks"></a> [private\_subnets\_cidr\_blocks](#input\_private\_subnets\_cidr\_blocks) | SSH CIDR blocks for existing Private Subnets. If not provided, the private subnets CIDR blocks from a new VPC are taken. | `list(string)` | `[]` | no |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | Existing Private Subnet IDs. If not provided, the private subnets from a new VPC are taken. | `list(string)` | `[]` | no |
| <a name="input_public_subnet_id_bastion"></a> [public\_subnet\_id\_bastion](#input\_public\_subnet\_id\_bastion) | Existing Public Subnet ID to place the Bastion Host. When this value it is empty, the first public subnet from a new VPC is taken. | `string` | `""` | no |
| <a name="input_refresh_kubeconfig"></a> [refresh\_kubeconfig](#input\_refresh\_kubeconfig) | Refresh kubeconfig file with the new EKS cluster configuration. | `bool` | `false` | no |
| <a name="input_ssh_cidr_blocks_bastion"></a> [ssh\_cidr\_blocks\_bastion](#input\_ssh\_cidr\_blocks\_bastion) | SSH CIDR blocks with access to the EKS cluster from Bastion Host. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ssh_cidr_blocks_k8s"></a> [ssh\_cidr\_blocks\_k8s](#input\_ssh\_cidr\_blocks\_k8s) | SSH CIDR blocks with access to the EKS cluster K8s API | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Existing VPC ID. If not provided, a new VPC will be created. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ACM certificate ARN |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Buckets IDs |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | EFS ID |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | EKS cluster endpoint |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | EKS cluster ID |
| <a name="output_eks_cluster_version"></a> [eks\_cluster\_version](#output\_eks\_cluster\_version) | EKS cluster version |
| <a name="output_eks_oidc_provider"></a> [eks\_oidc\_provider](#output\_eks\_oidc\_provider) | EKS cluster OIDC issuer URL |
| <a name="output_kubeconfig_file"></a> [kubeconfig\_file](#output\_kubeconfig\_file) | Kubeconfig full file path |
| <a name="output_kubeconfig_update"></a> [kubeconfig\_update](#output\_kubeconfig\_update) | Update KUBECONFIG file |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
