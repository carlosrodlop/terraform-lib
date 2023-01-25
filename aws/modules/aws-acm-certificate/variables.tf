variable "domain_name" {
  type        = string
  description = "Domain name for the certificate. Hosted zone in Route53."
}

variable "subdomain" {
  type        = string
  description = "Subdomain name for the certificate. Wildcard (*) is allowed"
  default     = "*"
}
