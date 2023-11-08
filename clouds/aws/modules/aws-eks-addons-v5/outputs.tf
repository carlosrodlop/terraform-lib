output "route53_zone_id" {
  description = "Route 53 ID"
  value       = local.route53_zone_id
}

output "route53_zone_arn" {
  description = "Route 53 arn"
  value       = local.route53_zone_arn
}

output "velero_bucket_arn" {
  description = "Velero Bucket arn"
  value       = local.velero_bucket_arn
}

output "hosted_zone_type" {
  description = "Local Hosted zone type"
  value       = local.hosted_zone_type
}

output "eks_bp_addon_efs_driver" {
  description = "Local Eneblement for EFS driver"
  value       = local.eks_bp_addon_efs_driver
}

output "eks_bp_addon_external_dns" {
  description = "Local Enablement external_dns"
  value       = local.eks_bp_addon_external_dns
}

output "eks_bp_addon_aws_lb_controller" {
  description = "Local Enablement for AWS controller addon"
  value       = local.eks_bp_addon_aws_lb_controller
}

output "eks_bp_addon_ing_nginx_controller" {
  description = "Local Enablement for Nginx controller"
  value       = local.eks_bp_addon_ing_nginx_controller
}

output "eks_bp_addon_kube_prometheus_stack" {
  description = "Local enablement of Kube Prometheus Stack"
  value       = local.eks_bp_addon_kube_prometheus_stack
}

output "eks_bp_addon_velero" {
  description = "Local enablement for velero"
  value       = local.eks_bp_addon_velero
}

output "bp_v5_external_dns" {
  description = "External DNS values from Terraforn Blueprints Module"
  value       = module.eks_blueprints_addons.external_dns
}
