variable "tags" {
  description = "Tags to apply to resources."
  default     = {}
  type        = map(string)
}

variable "name" {
  description = "EKS Name."
  type        = string
}

#https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-ci-cloud
variable "k8s_version" {
  description = "Kubernetes version to use for the EKS cluster. Supported versions are 1.24. and 1.26"
  default     = "1.26"
  type        = string

  #https://docs.cloudbees.com/docs/cloudbees-common/latest/supported-platforms/cloudbees-ci-cloud#_kubernetes
  validation {
    condition     = contains(["1.24", "1.26"], var.k8s_version)
    error_message = "Provided Kubernetes version has not been tested."
  }
}

variable "k8s_instance_types" {
  description = "Map with instance types to use for the EKS cluster nodes for each node group. See https://aws.amazon.com/ec2/instance-types/"
  type        = map(list(string))
  default = {
    # Not Scalable
    "k8s-apps" = ["m5.8xlarge"]
    # Scalable
    "cb-apps"    = ["m5d.4xlarge"] #Use Md5 https://aws.amazon.com/about-aws/whats-new/2018/06/introducing-amazon-ec2-m5d-instances/
    "agent"      = ["m5.2xlarge"]
    "agent-spot" = ["m5.2xlarge"]
  }
}

variable "k8s_apps_node_size" {
  description = "Desired number of nodes for the k8s-apps node group. Node group is not scalable."
  type        = number
  default     = 1
  validation {
    condition     = var.k8s_apps_node_size >= 1
    error_message = "Accepted values: 1 or more Nodes."
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

variable "aws_tf_bp_version" {
  description = "AWS Terraform Blueprint Version"
  type        = string
  default     = "v5"

  validation {
    condition     = contains(["v4", "v5"], var.aws_tf_bp_version)
    error_message = "Provided Blueprint version does not exist. Accepted values: v4 or v5."
  }
}

variable "kubeconfig_file_update" {
  description = "Refresh kubeconfig file with the new EKS cluster configuration."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Existing VPC ID."
  type        = string
  default     = ""
}

variable "private_subnets_ids" {
  description = "Existing Private Subnet IDs."
  type        = list(string)
  default     = []
}

variable "private_subnets_cidr_blocks" {
  description = "SSH CIDR blocks for existing Private Subnets."
  default     = []
  type        = list(string)

  validation {
    condition     = contains([for block in var.private_subnets_cidr_blocks : try(cidrhost(block, 0), "")], "") == false
    error_message = "List of SSH CIDR blocks contains an invalid CIDR block."
  }
}

# https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-availability-zones.html
variable "azs" {
  description = "Availability Zones to use for the EKS cluster."
  type        = list(string)

}

variable "enable_efs" {
  description = "Enable EFS Storage for the EKS cluster."
  type        = bool
  default     = true
}

variable "s3_ci_backup_name" {
  description = "S3 Bucket Name for CI Backups."
  type        = string
}
