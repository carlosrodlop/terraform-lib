data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = var.private_hosted_zone
}

data "aws_s3_bucket" "velero" {
  bucket = var.velero_bucket_id
}

locals {
  route53_zone_id   = data.aws_route53_zone.this.id
  route53_zone_arn  = data.aws_route53_zone.this.arn
  velero_bucket_arn = data.aws_s3_bucket.velero.arn
  run_on_linux_nodes = [
    {
      name  = "nodeSelector.kubernetes\\.io/os"
      value = "linux"
    }
  ]
  helm_values_path = "${path.module}/../../../../libs/k8s/helm/values/aws-tf-blueprints"
  #helm_charts_path                   = "${path.module}/../../../../libs/k8s/helm/charts"
  hosted_zone_type                   = var.private_hosted_zone ? "private" : "public"
  eks_bp_addon_efs_driver            = trim(var.efs_id, " ") == "" ? false : true
  eks_bp_addon_external_dns          = alltrue([var.eks_bp_addon_external_dns, trim(local.route53_zone_id, " ") != ""])
  eks_bp_addon_aws_lb_controller     = alltrue([trim(var.lb_type, " ") == "alb"])
  eks_bp_addon_ing_nginx_controller  = alltrue([trim(var.lb_type, " ") == "nlb", trim(var.acm_certificate_arn, " ") != ""])
  eks_bp_addon_kube_prometheus_stack = alltrue([var.eks_bp_addon_kube_prometheus_stack, trim(var.domain_name, " ") != "", trim(var.acm_certificate_arn, " ") != ""])
  eks_bp_addon_velero                = alltrue([var.eks_bp_addon_velero, trim(var.velero_bucket_id, " ") != "", local.eks_bp_addon_efs_driver == false])
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.9.1" #ensure to update this to the latest/desired version

  cluster_name      = var.eks_cluster_id
  cluster_endpoint  = var.eks_cluster_endpoint
  oidc_provider_arn = var.eks_oidc_provider_arn
  cluster_version   = var.eks_cluster_version

  eks_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
    coredns    = {}
    vpc-cni    = {}
    kube-proxy = {}
  }

  # EBS CSI Driver is enabled by default
  enable_aws_efs_csi_driver = local.eks_bp_addon_efs_driver

  enable_metrics_server = true
  metrics_server = {
    set = local.run_on_linux_nodes
  }
  enable_cluster_autoscaler = var.eks_bp_addon_cluster_autoscaler
  cluster_autoscaler = {
    set = local.run_on_linux_nodes
  }
  enable_external_dns = local.eks_bp_addon_external_dns
  external_dns = {
    values = [templatefile("${local.helm_values_path}/external-dns-v5.yaml", {
      zoneDNS = var.domain_name
    })]
  }
  external_dns_route53_zone_arns      = [local.route53_zone_arn]
  enable_aws_load_balancer_controller = local.eks_bp_addon_aws_lb_controller
  aws_load_balancer_controller = {
    set = local.run_on_linux_nodes #NOTE: add VPC id https://aws-ia.github.io/terraform-aws-eks-blueprints-addons/main/addons/aws-load-balancer-controller/
  }
  enable_ingress_nginx = local.eks_bp_addon_ing_nginx_controller
  ingress_nginx = {
    values = [templatefile("${local.helm_values_path}/aws-nginx-nlb.yaml", {
      hostname = var.domain_name
      cert_arn = var.acm_certificate_arn
    })]
  }
  enable_kube_prometheus_stack = local.eks_bp_addon_kube_prometheus_stack
  kube_prometheus_stack = {
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

  enable_velero = local.eks_bp_addon_velero
  velero = {
    s3_backup_location = local.velero_bucket_arn
  }

  tags = var.tags
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.29.0"

  role_name_prefix = "${var.eks_cluster_id}-ebs-csi-driv"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}
