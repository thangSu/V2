output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "subnet_ids" {
  value = { 
    for k, s in aws_subnet.subnets : k => s.id 
  }
}
output "subnet_cidrs" {
  value = { 
    for k, s in aws_subnet.subnets : k => s.cidr_block
  }
}

output "secondary_subnets" {
  value = aws_subnet.secondary_subnets
}