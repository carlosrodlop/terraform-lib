output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = var.enable_acm ? module.acm[0].acm_certificate_arn : null
}

output "efs_id" {
  description = "EFS ID"
  value       = module.eks.efs_id
}

output "buckets" {
  description = "Buckets IDs"
  value       = [for bucket in module.s3_bucket : bucket.bucket_name]
}

output "kubeconfig_file" {
  description = "Kubeconfig full file path"
  value       = module.eks.kubeconfig_file_path
}

output "kubeconfig_update" {
  description = "Update KUBECONFIG file"
  value       = module.eks.kubeconfig_update
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.eks_cluster_id
}

output "eks_cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.eks_cluster_version
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.eks_cluster_version
}

output "eks_oidc_provider" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.eks_cluster_version
}
