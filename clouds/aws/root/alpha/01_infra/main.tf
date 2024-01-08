provider "aws" {
  region = var.aws_region
  #https://github.com/hashicorp/terraform-provider-aws/issues/19583
  /* default_tags {
    tags = local.tags
  } */
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = var.private_hosted_zone
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.eks_cluster_id
}

data "aws_availability_zones" "available" {}

locals {
  platform                    = "alpha"
  root                        = basename(abspath(path.module))
  workspace_suffix            = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  global_name                 = "${var.preffix}${local.workspace_suffix}"
  platform_name               = "${local.global_name}-${local.platform}"
  efs_name                    = "${local.platform_name}-efs"
  vpc_name                    = "${local.platform_name}-vpc"
  ec2_bastion_name            = "${local.platform_name}-bastion"
  s3_ci_backup_name           = "${local.global_name}-ci-backups"
  s3_velero_name              = "${local.global_name}-velero"
  s3_artifacts_name           = "${local.global_name}-artifacts"
  s3_bucket_list              = [local.s3_ci_backup_name, local.s3_artifacts_name, local.s3_velero_name]
  route53_zone_id             = data.aws_route53_zone.this.id
  azs                         = slice(data.aws_availability_zones.available.names, 0, var.azs_number)
  vpc_id                      = trim(var.vpc_id, " ") == "" && module.vpc[0] != null ? module.vpc[0].vpc_id : trim(var.vpc_id, " ")
  vpc_cidr                    = "10.0.0.0/16"
  private_subnet_ids          = length(var.private_subnets_ids) == 0 && module.vpc[0] != null ? module.vpc[0].private_subnets : var.private_subnets_ids
  private_subnets_cidr_blocks = length(var.private_subnets_cidr_blocks) == 0 ? module.vpc[0].private_subnets_cidr_blocks : var.private_subnets_cidr_blocks
  enable_acm                  = alltrue([var.enable_acm])
  enable_bastion              = alltrue([var.enable_bastion, trim(var.key_name_bastion, " ") != "", length(var.ssh_cidr_blocks_bastion) > 0])
  # To enable VPC (create a new one): Requires empty values for vpc_id, private_subnets_ids and private_subnets_cidr_blocks
  enable_vpc = alltrue([trim(var.vpc_id, " ") == "", length(var.private_subnets_ids) == 0, length(var.private_subnets_cidr_blocks) == 0])
  enable_efs = alltrue([var.enable_efs, length(local.private_subnet_ids) > 0, length(local.azs) > 0, length(local.private_subnets_cidr_blocks) > 0])

  tags = merge(var.tags, {
    "tf:preffix"        = var.preffix
    "tf:blueprint_root" = local.root
  })
}

################################################################################
# Pre-requisites
################################################################################

#Global Resources
module "acm" {
  count   = local.enable_acm ? 1 : 0
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  #Important: Application Services Hostname must be the same as the domain name or subject_alternative_names
  domain_name = var.domain_name
  subject_alternative_names = [
    "ci.${var.domain_name}",
    "*.${var.domain_name}", # For subdomains example.${var.domain_name}
    "cd.${var.domain_name}"
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

  enable_nat_gateway = true
  single_nat_gateway = true

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
  source                 = "../../../modules/aws-eks"
  name                   = local.platform_name
  k8s_version            = var.k8s_version
  k8s_instance_types     = var.k8s_instance_types
  k8s_apps_node_size     = var.k8s_apps_node_size
  k8s_api_public         = var.k8s_api_public
  k8s_api_private        = var.k8s_api_private
  ssh_cidr_blocks_k8s    = var.ssh_cidr_blocks_k8s
  kubeconfig_file_update = var.kubeconfig_file_update
  aws_tf_bp_version      = var.aws_tf_bp_version
  vpc_id                 = local.vpc_id
  private_subnets_ids    = local.private_subnet_ids
  s3_ci_backup_name      = local.s3_ci_backup_name
  tags                   = local.tags

}

################################################################################
# Supported Infrastructure
################################################################################

module "bastion" {
  count  = local.enable_bastion ? 1 : 0
  source = "../../../modules/aws-bastion"

  key_name                 = var.key_name_bastion
  resource_prefix          = local.ec2_bastion_name
  source_security_group_id = module.eks.eks_node_security_group_id
  ssh_cidr_blocks          = var.ssh_cidr_blocks_bastion
  #Note: It requires to be here not in local to match if local.enable_bastion ? 1 : 0
  subnet_id = trim(var.public_subnet_id_bastion, " ") == "" ? module.vpc[0].public_subnets[0] : var.public_subnet_id_bastion
  vpc_id    = local.vpc_id
}

#Global Resources
module "s3_bucket" {
  source      = "../../../modules/aws-s3-bucket"
  for_each    = toset(local.s3_bucket_list)
  bucket_name = each.key

  force_destroy = true
  #SECO-3109
  enable_object_lock = false
  tags               = local.tags
}

module "efs" {
  count   = local.enable_efs ? 1 : 0
  source  = "terraform-aws-modules/efs/aws"
  version = "1.2.0"

  creation_token = local.efs_name
  name           = local.efs_name

  mount_targets = {
    for k, v in zipmap(local.azs, local.private_subnet_ids) : k => { subnet_id = v }
  }
  security_group_description = "${local.efs_name} EFS security group"
  security_group_vpc_id      = local.vpc_id
  #https://d1.awsstatic.com/events/reinvent/2021/Amazon_EFS_performance_best_practices_STG403.pdf
  #https://docs.cloudbees.com/docs/cloudbees-ci/latest/eks-install-guide/eks-pre-install-requirements-helm#_storage_requirements
  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = local.private_subnets_cidr_blocks
    }
  }

  tags = var.tags
}
