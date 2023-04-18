# eks-bp-v5

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.5 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.62.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.19.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.3.2 |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | ~> 1.0 |
| <a name="module_eks_blueprints"></a> [eks\_blueprints](#module\_eks\_blueprints) | github.com/aws-ia/terraform-aws-eks-blueprints | v4.24.0 |
| <a name="module_eks_blueprints_kubernetes_addons"></a> [eks\_blueprints\_kubernetes\_addons](#module\_eks\_blueprints\_kubernetes\_addons) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons | v4.24.0 |
| <a name="module_eks_velero"></a> [eks\_velero](#module\_eks\_velero) | ../../modules/aws-eks-velero | n/a |
| <a name="module_node_problem_detector"></a> [node\_problem\_detector](#module\_node\_problem\_detector) | ../../../shared/modules/k8s-node-problem-detector | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/aws-vpc-eks | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.managed_ng](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [helm_release.kube_prometheus_stack_local](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_annotations.gp2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_storage_class_v1.efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [null_resource.update_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.managed_ng_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | An existing domain name maped to a Route 53 Hosted Zone | `string` | n/a | yes |
| <a name="input_enable_addon_cluster_autoscaler"></a> [enable\_addon\_cluster\_autoscaler](#input\_enable\_addon\_cluster\_autoscaler) | Enable cluster-autoscaler. Enabling autoscaling is a good practice. Disable this add-ons is useful to demostrate its consequences. | `bool` | `true` | no |
| <a name="input_enable_addon_global"></a> [enable\_addon\_global](#input\_enable\_addon\_global) | Enable Kubernetes addons for EKS Blueprints. Helm provider. | `bool` | `true` | no |
| <a name="input_enable_addon_kube_prometheus_stack"></a> [enable\_addon\_kube\_prometheus\_stack](#input\_enable\_addon\_kube\_prometheus\_stack) | Enable kube-prometheus-stack. | `bool` | `true` | no |
| <a name="input_enable_node_problem_detector"></a> [enable\_node\_problem\_detector](#input\_enable\_node\_problem\_detector) | Enable enable\_node\_problem\_detector. | `bool` | `true` | no |
| <a name="input_enable_velero_backup"></a> [enable\_velero\_backup](#input\_enable\_velero\_backup) | Enable Velero for Backups. | `bool` | `true` | no |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Grafana admin password. | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use for the EKS cluster. Supported versions are 1.23 and 1.24. | `string` | `"1.24"` | no |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | Type of load balancer to use. | `string` | `"alb"` | no |
| <a name="input_preffix"></a> [preffix](#input\_preffix) | Preffix of the demo | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_windows_nodes"></a> [windows\_nodes](#input\_windows\_nodes) | Enable Windows nodes for Agents Node Pool. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ACM certificate ARN |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_kubeconfig_file_path"></a> [kubeconfig\_file\_path](#output\_kubeconfig\_file\_path) | Kubeconfig full file path |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
