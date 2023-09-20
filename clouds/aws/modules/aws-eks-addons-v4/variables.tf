variable "tags" {
  description = "Tags to apply to resources."
  default     = {}
  type        = map(string)
}

variable "domain_name" {
  description = "An existing domain name maped to a Route 53 Hosted Zone."
  type        = string
  validation {
    condition     = trim(var.domain_name, " ") != ""
    error_message = "Domain name must not be en empty string."
  }
}

variable "private_hosted_zone" {
  description = "Private Route 53 Hosted Zone Type."
  default     = false
  type        = bool
}

################################################################################
# EKS
################################################################################

variable "eks_cluster_version" {
  description = "EKS cluster version."
  type        = string
}

variable "eks_cluster_id" {
  description = "EKS cluster ID."
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  type        = string
}

variable "eks_oidc_provider" {
  description = "EKS cluster OIDC issuer URL."
  type        = string
}

################################################################################
# EKS Add-ons
################################################################################


variable "efs_id" {
  description = "EFS ID"
  type        = string
  default     = ""
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

variable "acm_certificate_arn" {
  description = "ACM certificate ARN. It is used by the ALB/Nginx ingress controller."
  type        = string

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^arn", var.acm_certificate_arn))
    error_message = "For the certificate_arn should start with arn."
  }

}

variable "eks_bp_addon_cluster_autoscaler" {
  description = "Enable EKS blueprint add-on cluster-autoscaler. Chart: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler"
  default     = true
  type        = bool
}

variable "eks_bp_addon_external_dns" {
  description = "Enable EKS blueprint add-on External DNS. Chart: https://artifacthub.io/packages/helm/bitnami/external-dns."
  default     = true
  type        = bool
}


variable "eks_bp_addon_kube_prometheus_stack" {
  description = "Enable EKS blueprint add-on  kube-prometheus-stack. Chart: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack"
  default     = true
  type        = bool
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  default     = "change.me"
  type        = string
}

variable "eks_bp_addon_velero" {
  description = "Enable EKS blueprint add-on Velero. It requires a valid S3 bucket. Chart: https://artifacthub.io/packages/helm/vmware-tanzu/velero"
  default     = true
  type        = bool
}

variable "velero_bucket_id" {
  description = "Velero S3 bucket ID."
  type        = string
}
