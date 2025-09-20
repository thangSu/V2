# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = var.vpc_name })
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
  tags = merge(var.tags, { Name = "${each.key}" },can(regex("public", each.key)) ? { "kubernetes.io/role/public-elb" : 1 } : {})
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = merge(var.tags, {Name: "${var.project-name}-nat-eip"})
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.subnets, aws_eip.nat_gateway_eip]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.subnets["public_subnet_1a"].id
  tags = merge(var.tags, {Name: "${var.project-name}-nat-gateway"})
}
