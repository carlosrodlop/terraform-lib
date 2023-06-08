provider "kubernetes" {
  config_path = var.kubeconfig_file
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_file
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks_cluster_id]
      command     = "aws"
    }
  }
}

locals {
  root = basename(abspath(path.module))
  tags = merge(var.tags, {
    "tf:blueprint_root" = local.root
  })
  helm_values_path = "${path.module}/../../../../libs/k8s/helm/values/aws-tf-blueprints"
  helm_charts_path = "${path.module}/../../../../libs/k8s/helm/charts"
}

module "eks_blueprints_kubernetes_addons" {
  count  = var.enable_addon_global ? 1 : 0
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.31.0"

  eks_cluster_id       = var.eks_cluster_id
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_oidc_provider    = var.eks_oidc_provider
  eks_cluster_version  = var.eks_cluster_version

  #Used by `ExternalDNS` to create DNS records in this Hosted Zone.
  eks_cluster_domain = var.domain_name

  # EKS Managed Add-ons
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/v4.24.0/docs/add-ons/managed-add-ons.md
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_efs_csi_driver            = true

  # Add-ons
  enable_metrics_server     = true
  enable_kube_state_metrics = true
  metrics_server_helm_config = {
    values = [file("${local.helm_values_path}/metric-server.yaml")]
  }
  enable_cluster_autoscaler = var.enable_addon_cluster_autoscaler
  cluster_autoscaler_helm_config = {
    values = [file("${local.helm_values_path}/cluster-autoscaler.yaml")]
  }
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller_helm_config = {
    #NOTE: Template not working
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }
  enable_external_dns = true
  external_dns_helm_config = {
    values = [templatefile("${local.helm_values_path}/external-dns.yaml", {
      zoneIdFilter = var.route53_zone_id
    })]
  }
  enable_ingress_nginx = var.lb_type == "nlb" ? true : false
  ingress_nginx_helm_config = var.lb_type == "nlb" ? {
    values = [templatefile("${local.helm_values_path}/aws-nginx-nlb.yaml", {
      hostname = var.domain_name
      cert_arn = var.acm_certificate_arn
    })]
  } : null

  enable_kube_prometheus_stack = var.enable_addon_kube_prometheus_stack
  kube_prometheus_stack_helm_config = var.enable_addon_kube_prometheus_stack ? {
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

  enable_vault = false

  tags = local.tags
}

resource "helm_release" "kube_prometheus_stack_local" {
  count            = var.enable_addon_global && var.enable_addon_kube_prometheus_stack ? 1 : 0
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

#---------------------------------------------------------------
# Storage Classes
#---------------------------------------------------------------

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
      # Annotation to set gp3 as default storage class
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  allow_volume_expansion = true
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    encrypted = true
    fsType    = "ext4"
    type      = "gp3"
  }

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]

}

resource "kubernetes_storage_class_v1" "efs" {
  metadata {
    name = "efs"
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap" # Dynamic provisioning
    fileSystemId     = var.efs_id
    directoryPerms   = "700"
  }

  mount_options = [
    "iam"
  ]

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]

}
