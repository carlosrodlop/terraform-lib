output "kubeconfig_file" {
  description = "Kubeconfig full file path"
  value       = local.kubeconfig_file_path
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.acm.acm_certificate_arn
}

output "eks_cluster_id" {
  description = "ACM certificate ARN"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.oidc_provider
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

output "efs_id" {
  description = "EFS ID"
  value       = module.efs.id
}

output "route53_zone_id" {
  description = "Route53 zone ID"
  value       = local.route53_zone_id
}
