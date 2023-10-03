data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = var.private_hosted_zone
}

locals {
  route53_zone_id = data.aws_route53_zone.this.id
  run_on_linux_nodes = [
    {
      name  = "nodeSelector.kubernetes\\.io/os"
      value = "linux"
    }
  ]
  helm_values_path                   = "${path.module}/../../../../libs/k8s/helm/values/aws-tf-blueprints"
  helm_charts_path                   = "${path.module}/../../../../libs/k8s/helm/charts"
  hosted_zone_type                   = var.private_hosted_zone ? "private" : "public"
  eks_bp_addon_efs_driver            = trim(var.efs_id, " ") == "" ? false : true
  eks_bp_addon_external_dns          = alltrue([var.eks_bp_addon_external_dns, trim(local.route53_zone_id, " ") != ""])
  eks_bp_addon_aws_lb_controller     = alltrue([trim(var.lb_type, " ") == "alb"])
  eks_bp_addon_ing_nginx_controller  = alltrue([trim(var.lb_type, " ") == "nlb", trim(var.acm_certificate_arn, " ") != ""])
  eks_bp_addon_kube_prometheus_stack = alltrue([var.eks_bp_addon_kube_prometheus_stack, trim(var.domain_name, " ") != "", trim(var.acm_certificate_arn, " ") != ""])
  eks_bp_addon_velero                = alltrue([var.eks_bp_addon_velero, trim(var.velero_bucket_id, " ") != "", local.eks_bp_addon_efs_driver == false])
}

module "eks_blueprints_addons" {
  #IMPORTANT: DO NOT CHANGE THE REFERENCE TO THE MODULE
  #Since 4.32.1 to avoid https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1630#issuecomment-1577525242
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  eks_cluster_id       = var.eks_cluster_id
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_oidc_provider    = var.eks_oidc_provider
  eks_cluster_version  = var.eks_cluster_version

  #Used by `ExternalDNS` to create DNS records in this Hosted Zone.
  eks_cluster_domain = var.domain_name

  # EKS Managed Add-ons
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/v4.24.0/docs/add-ons/managed-add-ons.md
  enable_amazon_eks_aws_ebs_csi_driver = true
  enable_aws_efs_csi_driver            = local.eks_bp_addon_efs_driver

  # Add-ons
  enable_metrics_server     = true
  enable_kube_state_metrics = true
  metrics_server_helm_config = {
    set = local.run_on_linux_nodes
  }
  enable_cluster_autoscaler = var.eks_bp_addon_cluster_autoscaler
  cluster_autoscaler_helm_config = {
    set = local.run_on_linux_nodes
  }

  enable_external_dns = local.eks_bp_addon_external_dns
  external_dns_helm_config = {
    values = [templatefile("${local.helm_values_path}/external-dns.yaml", {
      zoneIdFilter = local.route53_zone_id
      zoneType     = local.hosted_zone_type
    })]
  }

  enable_aws_load_balancer_controller = local.eks_bp_addon_aws_lb_controller
  aws_load_balancer_controller_helm_config = {
    set = local.run_on_linux_nodes
  }

  enable_ingress_nginx = local.eks_bp_addon_ing_nginx_controller
  ingress_nginx_helm_config = {
    values = [templatefile("${local.helm_values_path}/aws-nginx-nlb.yaml", {
      hostname = var.domain_name
      cert_arn = var.acm_certificate_arn
    })]
  }

  enable_kube_prometheus_stack = local.eks_bp_addon_kube_prometheus_stack
  kube_prometheus_stack_helm_config = {
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
  }

  enable_velero           = local.eks_bp_addon_velero
  velero_backup_s3_bucket = local.eks_bp_addon_velero ? var.velero_bucket_id : null

  tags = var.tags
}

resource "helm_release" "kube_prometheus_stack_local" {
  #count            = local.eks_bp_addon_kube_prometheus_stack ? 1 : 0
  count            = 0
  depends_on       = [module.eks_blueprints_addons]
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
  depends_on = [module.eks_blueprints_addons]
  source     = "../../../shared/modules/k8s-node-problem-detector"
}
