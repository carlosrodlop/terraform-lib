output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = var.enable_acm ? module.acm[0].acm_certificate_arn : null
}

output "efs_id" {
  description = "EFS ID"
  value       = var.enable_efs ? module.efs[0].id : null
}

output "buckets" {
  description = "Buckets IDs"
  value       = [for bucket in module.s3_bucket : bucket.bucket_name]
}

output "kubeconfig_file" {
  description = "Kubeconfig full file path"
  value       = local.kubeconfig_file_path
}

output "kubeconfig_update" {
  description = "Update KUBECONFIG file"
  value       = "aws eks update-kubeconfig --region ${local.current_region} --name ${local.cluster_name}"
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_name
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.oidc_provider
}
