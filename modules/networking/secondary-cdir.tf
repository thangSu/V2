# Create secondary CIDR blocks
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr_block" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.secondary_cidr_blocks
}

resource "aws_subnet" "secondary_subnets" {
  count = length(var.secondary_subnet_cidr_blocks)

  vpc_id = aws_vpc.vpc.id
  cidr_block = var.secondary_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.tags, { Name = "secondary-${count.index}" }) 
  depends_on = [ aws_vpc_ipv4_cidr_block_association.secondary_cidr_block ]
}
