# aws-eks-addons-v4

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.17 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.8 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons | v4.32.1 |
| <a name="module_node_problem_detector"></a> [node\_problem\_detector](#module\_node\_problem\_detector) | ../../../shared/modules/k8s-node-problem-detector | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.kube_prometheus_stack_local](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ACM certificate ARN. It is used by the ALB/Nginx ingress controller. | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | An existing domain name maped to a Route 53 Hosted Zone. | `string` | n/a | yes |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | EFS ID | `string` | `""` | no |
| <a name="input_eks_bp_addon_cluster_autoscaler"></a> [eks\_bp\_addon\_cluster\_autoscaler](#input\_eks\_bp\_addon\_cluster\_autoscaler) | Enable EKS blueprint add-on cluster-autoscaler. Chart: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler | `bool` | `true` | no |
| <a name="input_eks_bp_addon_external_dns"></a> [eks\_bp\_addon\_external\_dns](#input\_eks\_bp\_addon\_external\_dns) | Enable EKS blueprint add-on External DNS. Chart: https://artifacthub.io/packages/helm/bitnami/external-dns. | `bool` | `true` | no |
| <a name="input_eks_bp_addon_kube_prometheus_stack"></a> [eks\_bp\_addon\_kube\_prometheus\_stack](#input\_eks\_bp\_addon\_kube\_prometheus\_stack) | Enable EKS blueprint add-on  kube-prometheus-stack. Chart: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack | `bool` | `true` | no |
| <a name="input_eks_bp_addon_velero"></a> [eks\_bp\_addon\_velero](#input\_eks\_bp\_addon\_velero) | Enable EKS blueprint add-on Velero. It requires a valid S3 bucket. Chart: https://artifacthub.io/packages/helm/vmware-tanzu/velero | `bool` | `true` | no |
| <a name="input_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#input\_eks\_cluster\_endpoint) | EKS cluster endpoint. | `string` | n/a | yes |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | EKS cluster ID. | `string` | n/a | yes |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | EKS cluster version. | `string` | n/a | yes |
| <a name="input_eks_oidc_provider"></a> [eks\_oidc\_provider](#input\_eks\_oidc\_provider) | EKS cluster OIDC issuer URL. | `string` | n/a | yes |
| <a name="input_grafana_admin_password"></a> [grafana\_admin\_password](#input\_grafana\_admin\_password) | Grafana admin password. | `string` | `"change.me"` | no |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | Type of load balancer to use. | `string` | `"alb"` | no |
| <a name="input_private_hosted_zone"></a> [private\_hosted\_zone](#input\_private\_hosted\_zone) | Private Route 53 Hosted Zone Type. | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources. | `map(string)` | `{}` | no |
| <a name="input_velero_bucket_id"></a> [velero\_bucket\_id](#input\_velero\_bucket\_id) | Velero S3 bucket ID. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
