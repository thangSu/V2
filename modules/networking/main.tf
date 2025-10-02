module "vpc_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"
  context = module.this.context
  attributes = ["vpc"]
}

module "subnet_label" {
  source  = "cloudposse/label/null"

  for_each = local.subnets_list
  version = "0.24.1"
  context = module.this.context
  attributes = [ each.key ]
}

module "eip_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"
  context = module.this.context
  attributes = ["eip", "nat-gw"]
}
module "nat_gw_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"
  context = module.this.context
  attributes = ["nat-gw"]
}
# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = module.vpc_label.tags
}



locals {
  subnets_list = merge([
    for group in var.subnets : group
  ]...)
}
# Create subnets
resource "aws_subnet" "subnets" {
  for_each = local.subnets_list

  vpc_id = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  tags = merge(
    module.subnet_label[each.key].tags,
    can(regex("public", each.key)) ? { "kubernetes.io/role/public-elb" : 1 } : {}
  )
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = module.eip_label.tags
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.subnets, aws_eip.nat_gateway_eip]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.subnets["public-subnet-1a"].id
  tags = module.nat_gw_label.tags
}
