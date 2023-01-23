variable "preffix" {
  description = "Preffix of the demo"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}
