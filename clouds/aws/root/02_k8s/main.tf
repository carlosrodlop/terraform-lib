provider "aws" {
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
  eks_efs_driver = trim(var.efs_id, " ") == "" ? false : true
}

module "aws_eks_addons" {
  source = "../../modules/aws-eks-addons-v4"
  #source = "../../modules/aws-eks-addons-v5"

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

resource "kubernetes_annotations" "gp2" {
  depends_on  = [module.aws_eks_addons]
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  # This is true because the resources was already created by the ebs-csi-driver addon
  force = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still reatain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

resource "kubernetes_storage_class_v1" "gp3" {
  depends_on = [module.aws_eks_addons]
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = local.eks_efs_driver ? "false" : "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    encrypted = "true"
    fsType    = "ext4"
    type      = "gp3"
  }
}

resource "kubernetes_storage_class_v1" "efs" {
  depends_on = [module.aws_eks_addons]
  count      = local.eks_efs_driver ? 1 : 0
  metadata {
    name = "efs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = var.efs_id
    directoryPerms   = "700"
    uid              = "1000" #For CloudBees CI and CD
  }

  mount_options = [
    "iam"
  ]
}
