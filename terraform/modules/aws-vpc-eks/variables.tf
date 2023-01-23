variable "name" {
  description = "VPC name"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name to attach the VPC"
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
