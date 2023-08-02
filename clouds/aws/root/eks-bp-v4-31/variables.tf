
################################################################################
# General
################################################################################

variable "preffix" {
  description = "Preffix of the demo. Used for tagging and naming resources. Must be unique."
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  default     = {}
  type        = map(string)
}

variable "domain_name" {
  description = "An existing domain name maped to a Route 53 Hosted Zone"
  type        = string
}

################################################################################
# EKS
################################################################################

#https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-ci-cloud
variable "k8s_version" {
  description = "Kubernetes version to use for the EKS cluster. Supported versions are 1.23 and 1.24."
  default     = "1.24"
  type        = string

  validation {
    condition     = contains(["1.23", "1.24"], var.k8s_version)
    error_message = "Provided Kubernetes version is not supported by EKS and/or CloudBees."
  }
}

variable "k8s_instance_types" {
  description = "Map with instance types to use for the EKS cluster nodes for each node group."
  type        = map(list(string))
  default = {
    "k8s-apps"   = ["m5d.4xlarge"]
    "cb-apps"    = ["m5.8xlarge"]
    "agent"      = ["m5.4xlarge"]
    "agent-spot" = ["m5.4xlarge"]
  }
}

variable "k8s_api_public" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "k8s_api_private" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks_k8s" {
  description = "SSH CIDR blocks with access to the EKS cluster K8s API"
  # Any IP address
  default = ["0.0.0.0/0"]
  type    = list(string)

  validation {
    condition     = contains([for block in var.ssh_cidr_blocks_k8s : try(cidrhost(block, 0), "")], "") == false
    error_message = "List of SSH CIDR blocks contains an invalid CIDR block."
  }
}

################################################################################
# Bastion Host
################################################################################

/* Alternatives to Bastion Host
- System Manager https://aws.amazon.com/blogs/mt/replacing-a-bastion-host-with-amazon-ec2-systems-manager/
- Instance Connect Endpoint https://aws.amazon.com/blogs/compute/secure-connectivity-from-public-to-private-introducing-ec2-instance-connect-endpoint-june-13-2023/
*/
variable "enable_bastion" {
  description = "Enable Bastion Host for Private only EKS endpoints"
  type        = bool
  default     = false
}

variable "ssh_cidr_blocks_bastion" {
  description = "SSH CIDR blocks with access to the EKS cluster from Bastion Host"
  default     = ["0.0.0.0/0"]
  type        = list(string)

  validation {
    condition     = contains([for block in var.ssh_cidr_blocks_bastion : try(cidrhost(block, 0), "")], "") == false
    error_message = "List of SSH CIDR blocks contains an invalid CIDR block."
  }
}

variable "key_name_bastion" {
  description = "Name of the Existing Key Pair Name from EC2 to use for ssh into the Bastion Host instance"
  type        = string
}

variable "public_subnet_id_bastion" {
  description = "Existing Public Subnet ID to place the Bastion Host. When this value it is empty, the first public subnet from a new VPC is taken."
  type        = string
  default     = ""
}

################################################################################
# VPC
################################################################################

variable "vpc_id" {
  description = "Existing VPC ID. If not provided, a new VPC will be created."
  type        = string
  default     = ""
}

variable "private_subnets_ids" {
  description = "Existing Private Subnet IDs. If not provided, the private subnets from a new VPC are taken."
  type        = list(string)
  default     = []
}

variable "private_subnets_cidr_blocks" {
  description = "SSH CIDR blocks for existing Private Subnets. If not provided, the private subnets CIDR blocks from a new VPC are taken."
  default     = []
  type        = list(string)

  validation {
    condition     = contains([for block in var.private_subnets_cidr_blocks : try(cidrhost(block, 0), "")], "") == false
    error_message = "List of SSH CIDR blocks contains an invalid CIDR block."
  }
}

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-availability-zones.html
variable "azs_number" {
  description = "Number of Availability Zones to use for the VPC for the Selected Region. Minimum 2 for HA."
  type        = number
  default     = 3

  validation {
    condition     = var.azs_number >= 2
    error_message = "Accepted values: 2 or more."
  }
}

################################################################################
# Others resources
################################################################################

variable "enable_acm" {
  description = "Enable ACM Certificate for the EKS cluster ingress"
  type        = bool
  default     = true
}

variable "enable_efs" {
  description = "Enable EFS Storage for the EKS cluster"
  type        = bool
  default     = true
}
