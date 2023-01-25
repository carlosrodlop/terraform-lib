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
  root = basename(abspath(path.module))

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

  external_dns_helm_config = {
    values = [templatefile("${path.module}/external_dns-values.yaml", {
      zoneIdFilter = data.aws_route53_zone.this.id
    })]
  }
}
