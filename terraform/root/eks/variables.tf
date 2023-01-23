variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}

variable "domain_name" {
  description = "An existing domain name maped to a Route 53 Hosted Zone"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS cluster ID"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "Target EKS cluster endpoint"
  type        = string
}

variable "eks_oidc_provider" {
  description = "Target EKS cluster OIDC provider"
  type        = string
}

variable "eks_cluster_version" {
  description = "Target EKS cluster version"
  type        = string
}
