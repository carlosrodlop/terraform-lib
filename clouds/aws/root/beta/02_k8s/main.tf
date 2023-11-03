provider "aws" {
  region = var.aws_region
  #https://github.com/hashicorp/terraform-provider-aws/issues/19583
  /* default_tags {
    tags = local.tags
  } */
}

provider "kubernetes" {
  config_path = var.kubeconfig_file
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_file
  }
}

locals {
  root = basename(abspath(path.module))
  tags = merge(var.tags, {
    "tf:preffix"        = var.preffix
    "tf:blueprint_root" = local.root
  })
}

################################################################################
# EKS-Addons
################################################################################

module "eks_addons" {
  source = "../../../modules/aws-eks-addons-v4"

  eks_cluster_version                = var.eks_cluster_version
  eks_cluster_id                     = var.eks_cluster_id
  eks_cluster_endpoint               = var.eks_cluster_endpoint
  eks_oidc_provider                  = var.eks_oidc_provider
  efs_id                             = var.efs_id
  lb_type                            = var.lb_type
  domain_name                        = var.domain_name
  private_hosted_zone                = var.private_hosted_zone
  grafana_admin_password             = var.grafana_admin_password
  acm_certificate_arn                = var.acm_certificate_arn
  eks_bp_addon_cluster_autoscaler    = var.eks_bp_addon_cluster_autoscaler
  eks_bp_addon_external_dns          = var.eks_bp_addon_external_dns
  eks_bp_addon_kube_prometheus_stack = var.eks_bp_addon_kube_prometheus_stack
  eks_bp_addon_velero                = var.eks_bp_addon_velero
  velero_bucket_id                   = var.velero_bucket_id
  tags                               = local.tags
}

################################################################################
# Storage Classes
################################################################################

module "eks_sc" {
  source     = "../../../modules/aws-eks-sc"
  depends_on = [module.eks_addons]

  efs_id = var.efs_id
}
