output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.acm_certificate.certificate_arn
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_cluster_id
}

output "eks_cluster_version" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_cluster_version
}

output "eks_cluster_endpoint" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.eks_cluster_endpoint
}

output "eks_oidc_provider" {
  description = "EKS cluster ID"
  value       = module.eks_blueprints.oidc_provider
}

output "kubeconfig_file_path" {
  description = "Kubeconfig full file path"
  value       = abspath("${path.root}/${local.kubeconfig_file}")
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}
