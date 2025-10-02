module "ig_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"
  context = module.this.context
  attributes = ["route-tables"]
  
}

module "route_table_label" {
  source  = "cloudposse/label/null"
  for_each = toset(var.route_tables)
  version = "0.24.1"
  context = module.this.context
  attributes = [each.value, "rt"]
  
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = module.ig_label.tags
  depends_on = [ aws_vpc.vpc ]
}

resource "aws_route_table" "route_tables" {
  for_each = toset(var.route_tables)
  vpc_id = aws_vpc.vpc.id
  tags = module.route_table_label[each.value].tags
}

resource "aws_route_table_association" "aws_route_table_association"{
  for_each = local.subnets_list
  subnet_id = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.value.route_table].id
}

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.route_tables["public"].id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "app_route" {
  route_table_id = aws_route_table.route_tables["app"].id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat_gateway.id
}