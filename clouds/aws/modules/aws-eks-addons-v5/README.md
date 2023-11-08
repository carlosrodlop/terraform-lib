# aws-eks-addons-v5

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_driver_irsa"></a> [ebs\_csi\_driver\_irsa](#module\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.29.0 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | 1.9.1 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_s3_bucket.velero](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

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

| Name | Description |
|------|-------------|
| <a name="output_bp_v5_external_dns"></a> [bp\_v5\_external\_dns](#output\_bp\_v5\_external\_dns) | External DNS values from Terraforn Blueprints Module |
| <a name="output_eks_bp_addon_aws_lb_controller"></a> [eks\_bp\_addon\_aws\_lb\_controller](#output\_eks\_bp\_addon\_aws\_lb\_controller) | Local Enablement for AWS controller addon |
| <a name="output_eks_bp_addon_efs_driver"></a> [eks\_bp\_addon\_efs\_driver](#output\_eks\_bp\_addon\_efs\_driver) | Local Eneblement for EFS driver |
| <a name="output_eks_bp_addon_external_dns"></a> [eks\_bp\_addon\_external\_dns](#output\_eks\_bp\_addon\_external\_dns) | Local Enablement external\_dns |
| <a name="output_eks_bp_addon_ing_nginx_controller"></a> [eks\_bp\_addon\_ing\_nginx\_controller](#output\_eks\_bp\_addon\_ing\_nginx\_controller) | Local Enablement for Nginx controller |
| <a name="output_eks_bp_addon_kube_prometheus_stack"></a> [eks\_bp\_addon\_kube\_prometheus\_stack](#output\_eks\_bp\_addon\_kube\_prometheus\_stack) | Local enablement of Kube Prometheus Stack |
| <a name="output_eks_bp_addon_velero"></a> [eks\_bp\_addon\_velero](#output\_eks\_bp\_addon\_velero) | Local enablement for velero |
| <a name="output_hosted_zone_type"></a> [hosted\_zone\_type](#output\_hosted\_zone\_type) | Local Hosted zone type |
| <a name="output_route53_zone_arn"></a> [route53\_zone\_arn](#output\_route53\_zone\_arn) | Route 53 arn |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | Route 53 ID |
| <a name="output_velero_bucket_arn"></a> [velero\_bucket\_arn](#output\_velero\_bucket\_arn) | Velero Bucket arn |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
