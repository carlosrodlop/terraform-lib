variable "name" {
  description = "VPC name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
  type        = string
}

variable "public_subnet_tags" {
  description = "value for Public Subnets tags"
  type        = map(string)
}

variable "private_subnet_tags" {
  description = "value for Private Subnets tags"
  type        = map(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}

variable "azs" {
  description = "Availability Zones to use"
  type        = list(string)
}
