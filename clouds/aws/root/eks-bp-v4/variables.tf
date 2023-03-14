variable "preffix" {
  description = "Preffix of the demo"
  type        = string
}

#https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-ci-cloud
variable "kubernetes_version" {
  default = "1.24"
  type    = string

  validation {
    condition     = contains(["1.23", "1.24"], var.kubernetes_version)
    error_message = "Provided Kubernetes version is not supported by EKS and/or CloudBees."
  }
}

variable "domain_name" {
  description = "An existing domain name maped to a Route 53 Hosted Zone"
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

variable "refresh_kubeconf" {
  description = "Refresh kubeconfig file."
  default     = false
  type        = bool
}

variable "windows_nodes" {
  description = "Enable Windows nodes for Agents Node Pool."
  default     = false
  type        = bool
}


variable "grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
}

variable "alertmanager_to_mail" {
  description = "Alertmanager to mail."
  type        = string
}

variable "alertmanager_from_mail" {
  description = "Alertmanager from mail."
  type        = string
}

variable "alertmanager_from_mail_smarthost" {
  description = "Alertmanager from mail."
  type        = string
}

variable "alertmanager_from_mail_password" {
  description = "Alertmanager from mail."
  type        = string
}

variable "enable_addon_global" {
  description = "Enable Kubernetes addons for EKS Blueprints. Helm provider."
  default     = true
  type        = bool
}

variable "enable_addon_kube_prometheus_stack" {
  description = "Enable kube-prometheus-stack."
  default     = true
  type        = bool
}
