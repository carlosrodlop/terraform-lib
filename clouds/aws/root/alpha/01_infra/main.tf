provider "aws" {
  region = var.aws_region
  #https://github.com/hashicorp/terraform-provider-aws/issues/19583
  /* default_tags {
    tags = local.tags
  } */
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = var.private_hosted_zone
}

data "aws_availability_zones" "available" {}

locals {
  platform                    = "alpha"
  root                        = basename(abspath(path.module))
  workspace_suffix            = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  platform_name               = "${var.preffix}${local.workspace_suffix}-${local.platform}"
  global_name                 = "${var.preffix}${local.workspace_suffix}"
  vpc_name                    = "${local.platform_name}-vpc"
  ec2_bastion_name            = "${local.platform_name}-bastion"
  s3_ci_backup_name           = "${local.global_name}-ci-backups"
  s3_velero_name              = "${local.global_name}-velero"
  s3_artifacts_name           = "${local.global_name}-artifacts"
  s3_bucket_list              = [local.s3_ci_backup_name, local.s3_artifacts_name, local.s3_velero_name]
  route53_zone_id             = data.aws_route53_zone.this.id
  azs                         = slice(data.aws_availability_zones.available.names, 0, var.azs_number)
  vpc_id                      = trim(var.vpc_id, " ") == "" ? module.vpc[0].vpc_id : trim(var.vpc_id, " ")
  vpc_cidr                    = "10.0.0.0/16"
  private_subnet_ids          = length(var.private_subnets_ids) == 0 ? module.vpc[0].private_subnets : var.private_subnets_ids
  private_subnets_cidr_blocks = length(var.private_subnets_cidr_blocks) == 0 ? module.vpc[0].private_subnets_cidr_blocks : var.private_subnets_cidr_blocks
  enable_bastion              = alltrue([var.enable_bastion, trim(var.key_name_bastion, " ") != "", length(var.ssh_cidr_blocks_bastion) > 0])
  enable_acm                  = alltrue([var.enable_acm])
  enable_vpc                  = alltrue([trim(var.vpc_id, " ") == ""])

  tags = merge(var.tags, {
    "tf:preffix"        = var.preffix
    "tf:blueprint_root" = local.root
  })

}

################################################################################
# Pre-requisites
################################################################################

module "acm" {
  count   = local.enable_acm ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = var.domain_name
  subject_alternative_names = [
    "*.ci.${var.domain_name}",
    "*.cd.${var.domain_name}",
    "*.${var.domain_name}"
  ]

  #https://docs.aws.amazon.com/acm/latest/userguide/dns-validation.html
  zone_id = local.route53_zone_id

  tags = local.tags
}

module "vpc" {
  count   = local.enable_vpc ? 1 : 0
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs = local.azs
  # Ensure HA by creating different subnets in each AZ and connecting to an Autocaling Group
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.vpc_name}-default" }

  #https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  #https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = var.tags

}

################################################################################
# EKS: K8s Cluster
################################################################################

module "eks" {
  source                      = "../../../modules/aws-eks"
  name                        = local.platform_name
  k8s_version                 = var.k8s_version
  k8s_instance_types          = var.k8s_instance_types
  k8s_apps_node_size          = var.k8s_apps_node_size
  k8s_api_public              = var.k8s_api_public
  k8s_api_private             = var.k8s_api_private
  ssh_cidr_blocks_k8s         = var.ssh_cidr_blocks_k8s
  kubeconfig_file_update      = var.kubeconfig_file_update
  aws_tf_bp_version           = var.aws_tf_bp_version
  enable_efs                  = var.enable_efs
  vpc_id                      = local.vpc_id
  private_subnets_ids         = local.private_subnet_ids
  private_subnets_cidr_blocks = local.private_subnets_cidr_blocks
  azs                         = local.azs
  s3_ci_backup_name           = local.s3_ci_backup_name
  tags                        = local.tags

}

################################################################################
# Supported Infrastructure
################################################################################

module "bastion" {
  count  = local.enable_bastion ? 1 : 0
  source = "../../../modules/aws-bastion"

  key_name                 = var.key_name_bastion
  resource_prefix          = local.ec2_bastion_name
  source_security_group_id = module.eks.node_security_group_id
  ssh_cidr_blocks          = var.ssh_cidr_blocks_bastion
  subnet_id                = trim(var.public_subnet_id_bastion, " ") == "" ? module.vpc[0].public_subnets[0] : var.public_subnet_id_bastion
  vpc_id                   = local.vpc_id
}

# For Buckups, Artifacts and Cache
module "s3_bucket" {
  source      = "../../../modules/aws-s3-bucket"
  for_each    = toset(local.s3_bucket_list)
  bucket_name = each.key

  force_destroy = true
  #TODO: Fix InsufficientS3BucketPolicyException
  #https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html
  enable_logging = false
  #SECO-3109
  enable_object_lock = false
  tags               = local.tags
}
