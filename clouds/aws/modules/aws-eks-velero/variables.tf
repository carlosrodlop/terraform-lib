variable "bucket_name" {
  description = "Name of the S3 bucket to use for backups"
  type        = string
}

variable "k8s_cluster_oidc_arn" {
  description = "value of the OIDC provider ARN for the cluster"
  type        = string
}

variable "namespace" {
  description = "value of the namespace to install velero"
  default     = "velero"
  type        = string
}

variable "release_name" {
  description = "value of the release name for velero"
  default     = "velero"
  type        = string
}

variable "chart_version" {
  description = "value of the chart version for velero"
  default     = "2.29.6"
  type        = string
}
