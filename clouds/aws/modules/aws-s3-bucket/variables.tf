variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "force_destroy" {
  type        = bool
  description = "Allow deletion of non-empty bucket. It should not be enabled for production environments"
  default     = false
}

variable "is_tf_backend" {
  type        = bool
  description = "Is this bucket used as a Terraform backend?"
  default     = false
}

#SECO-3109 - Problem with Backups
variable "enable_object_lock" {
  type        = bool
  description = "Enable S3 bucket object lock"
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}
