module "eks_cluster_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["eks", "cluster"]
}
module "eks_cluster_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["eks", "cluster", "security-group"]
}
module "eks_node_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["eks", "node", "security-group"]
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = module.eks_cluster_label.id
  cluster_version = var.cluster_version

  bootstrap_self_managed_addons = false
  cluster_addons = local.managed_addons

  # Optional
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  # Optional: Adds the current caller identity as an administrator via cluster access entry
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    create_launch_template = true 
    # Fix over length naming issues
    use_name_prefix            = true
    iam_role_use_name_prefix   = false
    iam_role_attach_cni_policy = true
  }
  eks_managed_node_groups = local.eks_managed_nodegroups

  # access policy
  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"


  # Network
  create_cluster_primary_security_group_tags = false
  cluster_security_group_name = module.eks_cluster_sg_label.id
  cluster_security_group_description = module.eks_cluster_sg_label.id
  cluster_security_group_additional_rules = {
    ingress_from_pod_cidr = {
      description = "Allow access EKS Cluster from Pod CIDR"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [var.secondary_cidr_block]
    }
    ingress_from_access_cidrs = {
      description = "Allow access EKS Cluster"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks =  var.access_cidrs
    }
    ingress_from_all = {
      description = "Allow access EKS Cluster"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      cidr_blocks =  [
        "0.0.0.0/8"
      ]
    }
  }
  node_security_group_name = module.eks_node_sg_label.id
  node_security_group_description = module.eks_node_sg_label.id
  node_security_group_additional_rules = {
    allow_metrics_from_pod = {
      description = "Allow Metric Server Scrape"
      protocol    = "tcp"
      from_port   = 10250
      to_port     = 10250
      type        = "ingress"
      cidr_blocks = [var.secondary_cidr_block]   
    }
  }
  cluster_zonal_shift_config = {
    enabled = var.zonal_shift_config_enabled
  }
  tags = module.eks_cluster_label.tags
}