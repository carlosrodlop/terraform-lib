################################################################################
# Shared
################################################################################

variable "preffix" {
  description = "Preffix of the demo. Used for tagging and naming resources. Must be unique."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}

variable "domain_name" {
  description = "An existing domain name maped to a Route 53 Hosted Zone"
  type        = string
}

variable "hosted_zone_type" {
  description = "Route 53 Hosted Zone Type."
  default     = "public"
  type        = string

  validation {
    condition     = contains(["public", "private"], var.hosted_zone_type)
    error_message = "Hosted zone type must be either 'public' or 'private'."
  }
}

################################################################################
# EKS
################################################################################

variable "kubeconfig_file" {
  description = "Kubeconfig file path to be used as context for te Kubernetes provider."
  default     = "~/.kube/config"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS cluster ID"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  type        = string
}

variable "eks_oidc_provider" {
  description = "EKS cluster OIDC issuer URL"
  type        = string
}

################################################################################
# Storage
################################################################################

variable "efs_id" {
  description = "EFS ID"
  type        = string
  default     = ""
}

################################################################################
# EKS Add-ons
################################################################################

variable "lb_type" {
  description = "Type of load balancer to use."
  default     = "alb"
  type        = string

  validation {
    condition     = contains(["alb", "nlb"], var.lb_type)
    error_message = "Load balancer type must be either 'alb' or 'nlb'."
  }
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN. It is used by the ALB/Nginx ingress controller."
  type        = string

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^arn", var.acm_certificate_arn))
    error_message = "For the certificate_arn should start with arn"
  }

}

variable "enable_addon_cluster_autoscaler" {
  description = "Enable cluster-autoscaler."
  default     = true
  type        = bool
}

variable "enable_addon_external_dns" {
  description = "Enable External DNS."
  default     = true
  type        = bool
}

variable "enable_addon_kube_prometheus_stack" {
  description = "Enable kube-prometheus-stack."
  default     = true
  type        = bool
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  default     = "change.me"
  type        = string
}

variable "enable_addon_velero" {
  description = "Enable Velero. It requires a valid S3 bucket."
  default     = true
  type        = bool
}

variable "velero_bucket_id" {
  description = "Velero S3 bucket ID."
  type        = string
}
