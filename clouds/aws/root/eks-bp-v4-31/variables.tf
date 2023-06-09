variable "preffix" {
  description = "Preffix of the demo"
  type        = string
}

#https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-ci-cloud
variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster. Supported versions are 1.23 and 1.24."
  default     = "1.24"
  type        = string

  validation {
    condition     = contains(["1.23", "1.24"], var.kubernetes_version)
    error_message = "Provided Kubernetes version is not supported by EKS and/or CloudBees."
  }
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

variable "ssh_cidr_blocks" {
  description = "SSH CIDR blocks with access to the EKS cluster from Bastion Host"
  default     = ["0.0.0.0/0"]
  type        = list(string)

  validation {
    condition     = contains([for block in var.ssh_cidr_blocks : try(cidrhost(block, 0), "")], "") == false
    error_message = "List of SSH CIDR blocks contains an invalid CIDR block."
  }
}

variable "ssh_cidr_blocks_k8s_whitelist" {
  description = "SSH CIDR blocks with access to the EKS cluster K8s API"
  # Any IP address
  default = ["0.0.0.0/0"]
  type    = list(string)

  validation {
    condition     = contains([for block in var.ssh_cidr_blocks_k8s_whitelist : try(cidrhost(block, 0), "")], "") == false
    error_message = "List of SSH CIDR blocks contains an invalid CIDR block."
  }
}

variable "key_name" {
  description = "Name of the Key Pair to use for ssh into the Bastion Host instance"
  type        = string
}

variable "enable_bastion_host" {
  description = "Enable Bastion Host for Private only EKS endpoints"
  type        = bool
  default     = true
}

variable "create_acm" {
  description = "Create ACM Certificate for the EKS cluster ingress"
  type        = bool
  default     = true
}

/* variable "create_efs" {
  description = "Create EFS Storage for the EKS cluster"
  type        = bool
  default     = true
} */

variable "vpc_id" {
  description = "Existing VPC ID. If not provided, a new VPC will be created."
  type        = string
  default     = ""
}

variable "subnet_id_bastion" {
  description = "Existing Public Subnet ID to place the Bastion Host. If not provided, the first public subnet from the created VPC is taken."
  type        = string
  default     = ""
}

variable "subnet_id_list_eks" {
  description = "A list of subnet IDs where the EKS nodes/node groups will be provisioned. If not provided, the private subnets from the created VPC are taken."
  type        = list(string)
  default     = []
}
