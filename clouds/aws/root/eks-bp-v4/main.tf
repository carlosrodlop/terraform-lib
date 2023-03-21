provider "aws" {
  #https://github.com/hashicorp/terraform-provider-aws/issues/19583
  /* default_tags {
    tags = local.tags
  } */
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_route53_zone" "this" {
  name = var.domain_name
}

locals {
  root              = basename(abspath(path.module))
  workspace_suffix  = terraform.workspace == "default" ? "" : "_${terraform.workspace}"
  name              = "${var.preffix}${local.workspace_suffix}"
  vpc_name          = "${local.name}-vpc"
  cluster_name      = "${local.name}-eks"
  s3_backup_name    = "${local.name}.backups"
  oidc_provider_arn = module.eks_blueprints.eks_oidc_provider_arn
  route53_zone_id   = data.aws_route53_zone.this.id

  tags = merge(var.tags, {
    "tf:blueprint_root" = local.root
  })

  kubeconfig_file      = "kubeconfig-${module.eks_blueprints.eks_cluster_id}.yaml"
  kubeconfig_file_path = abspath("${path.root}/${local.kubeconfig_file}")
  helm_values_path     = "${path.module}/../../../../libs/k8s/helm/values/aws-tf-blueprints"
  helm_charts_path     = "${path.module}/../../../../libs/k8s/helm/charts"

}


module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3.2"

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

#https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
#https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
module "vpc" {
  source = "../../modules/aws-vpc-eks"

  name         = local.vpc_name
  cluster_name = local.cluster_name
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }

  tags = local.tags
}

#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.24.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  node_security_group_additional_rules = {
    egress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }

    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    egress_ssh_all = {
      description      = "Egress all ssh to internet for github"
      protocol         = "tcp"
      from_port        = 22
      to_port          = 22
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    # Allows Control Plane Nodes to talk to Worker nodes on all ports. Added this to simplify the example and further avoid issues with Add-ons communication with Control plane.
    # This can be restricted further to specific port based on the requirement for each Add-on e.g., metrics-server 4443, spark-operator 8080, karpenter 8443 etc.
    # Change this according to your security requirements if needed
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  managed_node_groups = {
    mg_58xL = {
      node_group_name = "managed-apps-ondemand"
      #https://aws.amazon.com/ec2/instance-types/
      instance_types = ["m5.8xlarge"]
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 6
      desired_size   = 1
      subnet_ids     = [] # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']
    },
    mg_54xL_agent = {
      node_group_name = "managed-agent"
      instance_types  = ["m5.4xlarge"]
      capacity_type   = "ON_DEMAND"
      min_size        = 1
      max_size        = 1
      desired_size    = 1
      subnet_ids      = [] # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']
      k8s_taints      = [{ key = "dedicated", value = "build-linux", effect = "NO_SCHEDULE" }]
    }
    mg_54xL_agent_spot = {
      node_group_name = "managed-agent-spot"
      instance_types  = ["m5.4xlarge"]
      capacity_type   = "SPOT"
      min_size        = 1
      max_size        = 6
      desired_size    = 1
      subnet_ids      = [] # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']
      k8s_taints      = [{ key = "dedicated", value = "build-linux", effect = "NO_SCHEDULE" }]
    }

  }
  #https://aws-ia.github.io/terraform-aws-eks-blueprints/v4.24.0/node-groups/#windows-self-managed-node-groups
  enable_windows_support = var.windows_nodes
  self_managed_node_groups = var.windows_nodes == true ? {
    ng_od_windows = {
      node_group_name    = "ng-od-windows"
      launch_template_os = "windows"
      instance_type      = "m5.large"
      subnet_ids         = [] # Defaults to private subnet-ids used by EKS Control plane. Define your private/public subnets list with comma separated subnet_ids  = ['subnet1','subnet2','subnet3']
      min_size           = 1
      max_size           = 3
      desired_size       = 1
      kubelet_extra_args = "--node-labels=WorkerType=ON_DEMAND,noderole=spark --register-with-taints=build-windows=dedicated:NoSchedule"
      #It seems not possible to add taints to windows nodes
      #k8s_taints         = [{ key = "dedicated", value = "build-linux", effect = "NO_SCHEDULE" }]
    }
  } : {}

  tags = local.tags

}

#https://www.bitslovers.com/terraform-null-resource/
resource "null_resource" "update_kubeconfig" {
  depends_on = [module.eks_blueprints]

  triggers = var.refresh_kubeconf == true ? {
    always_run = "${timestamp()}"
  } : null
  provisioner "local-exec" {
    command = "${module.eks_blueprints.configure_kubectl} --kubeconfig ${local.kubeconfig_file_path}"
  }
}

#---------------------------------------------------------------
# EKS Blueprints Add-ons
#---------------------------------------------------------------

module "eks_blueprints_kubernetes_addons" {
  count  = var.enable_addon_global ? 1 : 0
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.24.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  #Used by `ExternalDNS` to create DNS records in this Hosted Zone.
  eks_cluster_domain = var.domain_name

  # EKS Managed Add-ons
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/blob/v4.24.0/docs/add-ons/managed-add-ons.md
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_metrics_server = true
  metrics_server_helm_config = {
    values = [file("${local.helm_values_path}/metric-server.yaml")]
  }
  enable_cluster_autoscaler = true
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
      zoneIdFilter = local.route53_zone_id
    })]
  }
  enable_ingress_nginx = var.lb_type == "nlb" ? true : false
  ingress_nginx_helm_config = var.lb_type == "nlb" ? {
    values = [templatefile("${local.helm_values_path}/aws-nginx-nlb.yaml", {
      hostname = var.domain_name
      cert_arn = module.acm.acm_certificate_arn
    })]
  } : null
  enable_kube_prometheus_stack = var.enable_addon_kube_prometheus_stack
  kube_prometheus_stack_helm_config = var.enable_addon_kube_prometheus_stack ? {
    values = [
      templatefile("${local.helm_values_path}/kube-stack-prometheus.yaml", {
        alertmanager_to_mail             = var.alertmanager_to_mail
        alertmanager_from_mail           = var.alertmanager_from_mail
        alertmanager_from_mail_smarthost = var.alertmanager_from_mail_smarthost
        alertmanager_from_mail_password  = var.alertmanager_from_mail_password
      }),
      templatefile("${local.helm_values_path}/kube-stack-prometheus-grafana-alb.yaml", {
        hostname = "grafana.${var.domain_name}"
        cert_arn = module.acm.acm_certificate_arn
      })
    ]
    set_sensitive = [
      {
        name  = "grafana.adminPassword"
        value = var.grafana_admin_password
      }
    ]
  } : null

  tags = local.tags
}

module "velero_aws" {
  count      = var.enable_velero_backup ? 1 : 0
  source     = "../../modules/aws-eks-velero"
  depends_on = [module.eks_blueprints_kubernetes_addons]

  k8s_cluster_oidc_arn = local.oidc_provider_arn
  bucket_name          = local.s3_backup_name
}

resource "helm_release" "kube-prometheus-stack-local" {
  count            = var.enable_addon_kube_prometheus_stack ? 1 : 0
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
