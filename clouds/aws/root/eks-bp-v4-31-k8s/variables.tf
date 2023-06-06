variable "domain_name" {
  description = "An existing domain name maped to a Route 53 Hosted Zone"
  type        = string
}

variable "kubeconfig_file" {
  description = "Kubeconfig file path to be used as context"
  default     = "~/.kube/config"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}

variable "lb_type" {
  description = "Type of load balancer to use."
  default     = "alb"
  type        = string

  validation {
    condition     = contains(["alb", "nlb"], var.lb_type)
    error_message = "Load balancer type must be either 'alb' or 'nlb'."
  }
}

variable "enable_addon_global" {
  description = "Enable Kubernetes addons for EKS Blueprints. Helm provider."
  default     = true
  type        = bool
}

variable "enable_addon_cluster_autoscaler" {
  description = "Enable cluster-autoscaler. Enabling autoscaling is a good practice. Disable this add-ons is useful to demostrate its consequences."
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
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
  type        = string
}

variable "eks_cluster_id" {
  description = "ACM certificate ARN"
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

variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "efs_id" {
  description = "EFS ID"
  type        = string
}
