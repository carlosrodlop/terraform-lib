output "kubeconfig_file_path" {
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

output "eks_oidc_provider_arn" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.oidc_provider_arn
}

output "eks_cluster_certificate_authority_data" {
  description = "EKS cluster OIDC issuer URL"
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_node_security_group_id" {
  description = "EKS cluster node security group ID"
  value       = module.eks.node_security_group_id
}
