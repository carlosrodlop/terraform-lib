variable "preffix" {
  description = "Preffix of the demo"
  type        = string
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
