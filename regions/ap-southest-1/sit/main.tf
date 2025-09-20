module "this" {
  source  = "cloudposse/label/null"
  version = "0.24.1"
  namespace  = local.default.namespace
  stage      = local.default.stage
  name       = local.default.name
  delimiter  = "-"

  tags = local.default.tags
}

module "network" {

  source = "../../../modules/networking"

  vpc_name = local.network.vpc_name
  vpc_cidr = local.network.vpc_cidr

  subnets = local.network.subnets
  aws_region = local.default.aws_region
  secondary_subnet_cidr_blocks = local.network.secondary_subnets
  secondary_cidr_blocks = local.network.secondary_cidr_block
  route_tables = local.network.route_tables
  project-name = local.default.name
  tags = local.default.tags
}
locals {
  app_subnet_ids = [for k,v in local.network.subnets.app: module.network.subnet_ids[k]]
  app_subnet_cidrs = [for k,v in local.network.subnets.app: module.network.subnet_cidrs[k]]
}
# module "security_group" {
#   source = "../../../modules/security-group"
#   vpc_id = module.network.vpc_id
#   security_groups = local.network.security_groups
#   depends_on = [ local.network ]
# }

module "eks" {
  source = "../../../modules/eks"
  aws_region = local.default.aws_region
  vpc_id = module.network.vpc_id

  # Required attributes
  cluster_version              = local.eks.cluster_version
  cluster_addons               = local.eks.addons
  cluster_name                 = local.eks.cluster_name
  create_asg_role              = local.eks.create_asg_role
  secondary_subnets            = module.network.secondary_subnets
  secondary_cidr_block         = local.network.secondary_cidr_block
  zonal_shift_config_enabled   = local.eks.zonal_shift_config_enabled
  subnet_ids                   = local.app_subnet_ids
  context = module.this.context
  node_groups = local.eks.node_groups
  access_cidrs = local.app_subnet_cidrs
  depends_on = [ module.network]
}