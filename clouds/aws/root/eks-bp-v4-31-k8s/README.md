# eks-bp-v4-31-k8s

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | = 2.5.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.9.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.5.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.22.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints_kubernetes_addons"></a> [eks\_blueprints\_kubernetes\_addons](#module\_eks\_blueprints\_kubernetes\_addons) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons | v4.31.0 |
| <a name="module_node_problem_detector"></a> [node\_problem\_detector](#module\_node\_problem\_detector) | ../../../shared/modules/k8s-node-problem-detector | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.kube_prometheus_stack_local](https://registry.terraform.io/providers/hashicorp/helm/2.5.1/docs/resources/release) | resource |
| [kubernetes_annotations.gp2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_storage_class_v1.efs](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ACM certificate ARN. It is used by the ALB/Nginx ingress controller. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | An existing domain name maped to a Route 53 Hosted Zone | `string` | n/a | yes |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | EFS ID | `string` | `""` | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | EKS cluster endpoint | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS cluster ID | `string` | n/a | yes |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | EKS cluster version | `string` | n/a | yes |
| <a name="input_eks_oidc_provider"></a> [eks\_oidc\_provider](#input\_eks\_oidc\_provider) | EKS cluster OIDC issuer URL | `string` | n/a | yes |
| <a name="input_enable_addon_cluster_autoscaler"></a> [enable\_addon\_cluster\_autoscaler](#input\_enable\_addon\_cluster\_autoscaler) | Enable cluster-autoscaler. | `bool` | `true` | no |
| <a name="input_enable_addon_external_dns"></a> [enable\_addon\_external\_dns](#input\_enable\_addon\_external\_dns) | Enable External DNS. | `bool` | `true` | no |
| <a name="input_enable_addon_kube_prometheus_stack"></a> [enable\_addon\_kube\_prometheus\_stack](#input\_enable\_addon\_kube\_prometheus\_stack) | Enable kube-prometheus-stack. | `bool` | `true` | no |
| <a name="input_enable_addon_velero"></a> [enable\_addon\_velero](#input\_enable\_addon\_velero) | Enable Velero. It requires a valid S3 bucket. | `bool` | `true` | no |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Grafana admin password. | `string` | `"change.me"` | no |
| <a name="input_hosted_zone_type"></a> [hosted\_zone\_type](#input\_hosted\_zone\_type) | Route 53 Hosted Zone Type. | `string` | `"public"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | Kubeconfig file path to be used as context for te Kubernetes provider. | `string` | `"~/.kube/config"` | no |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | Type of load balancer to use. | `string` | `"alb"` | no |
| <a name="input_preffix"></a> [preffix](#input\_preffix) | Preffix of the demo. Used for tagging and naming resources. Must be unique. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_velero_bucket_id"></a> [velero\_bucket\_id](#input\_velero\_bucket\_id) | Velero S3 bucket ID. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
