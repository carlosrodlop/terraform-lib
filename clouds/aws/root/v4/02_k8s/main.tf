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

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = local.private_zone
}

locals {
  root = basename(abspath(path.module))
  tags = merge(var.tags, {
    "tf:preffix"        = var.preffix
    "tf:blueprint_root" = local.root
  })
  route53_zone_id   = data.aws_route53_zone.this.id
  private_zone      = var.hosted_zone_type == "private" ? true : false
  enable_efs_driver = trim(var.efs_id, " ") == "" ? false : true
  run_on_linux_nodes = [
    {
      name  = "nodeSelector.kubernetes\\.io/os"
      value = "linux"
    }
  ]
  helm_values_path                    = "${path.module}/../../../../../libs/k8s/helm/values/aws-tf-blueprints"
  helm_charts_path                    = "${path.module}/../../../../../libs/k8s/helm/charts"
  enable_addon_external_dns           = alltrue([var.enable_addon_external_dns, trim(var.hosted_zone_type, " ") != "", trim(local.route53_zone_id, " ") != ""])
  enable_aws_load_balancer_controller = alltrue([trim(var.lb_type, " ") == "alb"])
  enable_ingress_nginx                = alltrue([trim(var.lb_type, " ") == "nlb", trim(var.acm_certificate_arn, " ") != ""])
  enable_addon_kube_prometheus_stack  = alltrue([var.enable_addon_kube_prometheus_stack, trim(var.domain_name, " ") != ""])
  enable_addon_velero                 = alltrue([var.enable_addon_velero, trim(var.velero_bucket_id, " ") != ""])
}

######################################################
# EKS Add-ons
######################################################

module "eks_blueprints_kubernetes_addons" {
  #Note v4.32.1 support External DNS with Private Hosted Zones
  #Version > 4.32.1 to avoid https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1630#issuecomment-1577525242
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id       = var.eks_cluster_id
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_oidc_provider    = var.eks_oidc_provider
  eks_cluster_version  = var.eks_cluster_version

  #Used by `ExternalDNS` to create DNS records in this Hosted Zone.
  eks_cluster_domain = var.domain_name

  # Managed Add-ons
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/v4.24.0/docs/add-ons/managed-add-ons.md
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_efs_csi_driver            = local.enable_efs_driver

  # Add-ons
  enable_metrics_server     = true
  enable_kube_state_metrics = true
  metrics_server_helm_config = {
    set = local.run_on_linux_nodes
  }
  enable_cluster_autoscaler = var.enable_addon_cluster_autoscaler
  cluster_autoscaler_helm_config = var.enable_addon_cluster_autoscaler ? {
    set = local.run_on_linux_nodes
  } : null

  enable_external_dns = local.enable_addon_external_dns
  external_dns_helm_config = local.enable_addon_external_dns ? {
    values = [templatefile("${local.helm_values_path}/external-dns.yaml", {
      zoneIdFilter = local.route53_zone_id
      zoneType     = var.hosted_zone_type
    })]
  } : null

  enable_aws_load_balancer_controller = local.enable_aws_load_balancer_controller
  aws_load_balancer_controller_helm_config = local.enable_aws_load_balancer_controller ? {
    set = local.run_on_linux_nodes
  } : null

  enable_ingress_nginx = local.enable_ingress_nginx
  ingress_nginx_helm_config = local.enable_ingress_nginx ? {
    values = [templatefile("${local.helm_values_path}/aws-nginx-nlb.yaml", {
      hostname = var.domain_name
      cert_arn = var.acm_certificate_arn
    })]
  } : null

  enable_kube_prometheus_stack = local.enable_addon_kube_prometheus_stack
  kube_prometheus_stack_helm_config = local.enable_addon_kube_prometheus_stack ? {
    values = [
      file("${local.helm_values_path}/kube-prometheus-stack.yaml"),
      templatefile("${local.helm_values_path}/kube-prometheus-stack-grafana-alb.yaml", {
        hostname = "grafana.${var.domain_name}"
        cert_arn = var.acm_certificate_arn
      })
    ]
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = var.grafana_admin_password
      }
    ]
  } : null

  enable_velero           = local.enable_addon_velero
  velero_backup_s3_bucket = local.enable_addon_velero ? var.velero_bucket_id : null

  tags = local.tags
}


resource "helm_release" "kube_prometheus_stack_local" {
  count            = local.enable_addon_kube_prometheus_stack ? 1 : 0
  depends_on       = [module.eks_blueprints_kubernetes_addons]
  name             = "kube-prometheus-stack-local"
  chart            = "${local.helm_charts_path}/kube-prometheus-stack-local"
  namespace        = "kube-prometheus-stack"
  create_namespace = true
  timeout          = 1200
  wait             = true
  max_history      = 0
  version          = "0.1.4"
}

module "node_problem_detector" {
  depends_on = [module.eks_blueprints_kubernetes_addons]
  source     = "../../../../shared/modules/k8s-node-problem-detector"
}

######################################################
# Storage Classes
######################################################

resource "kubernetes_annotations" "gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }

  annotations = {
    # Modify annotations to remove gp2 as default storage class still reatain the class
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]

}

resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = local.enable_efs_driver ? "false" : "true"
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

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]

}

resource "kubernetes_storage_class_v1" "efs" {
  count = local.enable_efs_driver ? 1 : 0
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
    #uid              = "1000" #For CloudBees CI and CD
  }

  mount_options = [
    "iam"
  ]

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]

}
