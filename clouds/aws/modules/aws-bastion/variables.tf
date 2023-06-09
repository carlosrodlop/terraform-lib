variable "instance_type" {
  description = "Instance type to use for the Bastion Host"
  default     = "t3.small"
  type        = string
}

variable "instance_user" {
  description = "Bastion Host user"
  default     = "ec2-user"
  type        = string
}

variable "key_name" {
  description = "Name of the Key Pair to use for ssh into the Bastion Host instance. Assumes PEM format."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for the name of the resources created by this module"
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "CIDR block for the Security Group to allow SSH inbound traffic"
  type        = set(string)
}

variable "source_security_group_id" {
  description = "Security Group ID for the EKS Node groups"
  type        = string
}
variable "subnet_id" {
  description = "Subnet ID to place the Bastion Host in"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to place the Bastion Host in"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resources created by this module"
  default     = {}
  type        = map(string)
}
