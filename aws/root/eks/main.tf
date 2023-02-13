provider "aws" {
  default_tags {
    tags = local.tags
  }
}

data "aws_eks_cluster" "default" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "default" {
  name = var.eks_cluster_id
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

data "aws_acm_certificate" "issued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.default.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}

locals {
  root            = basename(abspath(path.module))
  route53_zone_id = data.aws_route53_zone.this.id
  acm_arn         = data.aws_acm_certificate.issued.arn

  tags = merge(var.tags, {
    "tf:blueprint_root" = local.root
  })
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.20.0"

  eks_cluster_id       = var.eks_cluster_id
  eks_cluster_endpoint = var.eks_cluster_endpoint
  eks_oidc_provider    = var.eks_oidc_provider
  eks_cluster_version  = var.eks_cluster_version

  #Used by `ExternalDNS` to create DNS records in this Hosted Zone.
  eks_cluster_domain = var.domain_name

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_metrics_server               = true
  enable_cluster_autoscaler           = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true
  #enable_kubernetes_dashboard         = true #TODO: Not working fill a bug report


  external_dns_helm_config = {
    values = [templatefile("${path.module}/helm/external_dns-values.yaml", {
      zoneIdFilter = local.route53_zone_id
    })]
  }

  /* kube_prometheus_stack_helm_config = {
    values = [templatefile("${path.module}/helm-values/kube-stack-prometheus-values.yaml", {
      hostname = "prometheus.${var.domain_name}"
    })]
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = aws_secretsmanager_secret_version.grafana.secret_string
      }
    ]
  } */

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    values = [templatefile("${path.module}/helm/nginx-values-nlb.yaml", {
      hostname     = var.domain_name
      ssl_cert_arn = local.acm_arn
    })]
  }

}

#---------------------------------------------------------------
# Monitoring
#---------------------------------------------------------------
/* resource "kubectl_manifest" "prometheus" {
  yaml_body = templatefile("monitoring/monitor.yaml", {
    namespace = local.namespace
  })

  depends_on = [
    module.eks_blueprints_kubernetes_addons
  ]
}

resource "random_password" "grafana" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "grafana" {
  name_prefix             = "grafana-"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id     = aws_secretsmanager_secret.grafana.id
  secret_string = random_password.grafana.result
} */
