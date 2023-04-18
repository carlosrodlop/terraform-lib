variable "namespace" {
  description = "value of the namespace to install node-problem-detector"
  default     = "node-problem-detector"
  type        = string
}

variable "release_name" {
  description = "value of the release name for node-problem-detector"
  default     = "node-problem-detector"
  type        = string
}

variable "chart_version" {
  description = "value of the chart version for node-problem-detector"
  default     = "2.3.4"
  type        = string
}
