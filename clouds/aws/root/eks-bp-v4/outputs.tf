output "kubeconfig_file_path" {
  description = "Kubeconfig full file path"
  value       = local.kubeconfig_file_path
}

output "configure_kubectl" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = module.eks_blueprints.configure_kubectl
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.acm.acm_certificate_arn
}
