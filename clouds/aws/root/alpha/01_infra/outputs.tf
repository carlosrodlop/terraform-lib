############################
#Global Resources
############################

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = var.enable_acm ? module.acm[0].acm_certificate_arn : null
}

output "buckets" {
  description = "Buckets IDs"
  value       = [for bucket in module.s3_bucket : bucket.bucket_name]
}

############################
#Regional Resources
############################

output "efs_id" {
  description = "EFS ID"
  value       = local.enable_efs ? module.efs[0].id : null
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
  value       = module.eks.eks_cluster_endpoint
}

output "eks_oidc_provider" {
  description = "EKS cluster OIDC issuer URL. Required for v4."
  value       = module.eks.eks_oidc_provider
}

output "eks_oidc_provider_arn" {
  description = "EKS cluster OIDC ARN. Required for v5."
  value       = module.eks.eks_oidc_provider
}

############################
#VPC: Not required by 02_k8s
############################

output "opt_vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

output "opt_vpc_private_subnets_ids" {
  description = "VPC Private Subnet ID"
  value       = [for private_subnet in local.private_subnet_ids : private_subnet]
}

output "opt_vpc_private_subnets_cidr_blocks" {
  description = "VPC Private Subnet ID"
  value       = [for private_subnet_block in local.private_subnets_cidr_blocks : private_subnet_block]
}
