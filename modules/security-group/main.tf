locals {
  ingress_rules = merge([
    for security_group_key, security_group in var.security_groups : {
      for ingress_rule in security_group.ingress_rules :
      "${security_group_key}-${ingress_rule.cidr}-${ingress_rule.port}" => {
        security_group_id = module.security_groups[security_group_key].security_group_id
        cidr_ipv4         = ingress_rule.cidr
        from_port         = ingress_rule.port
        to_port           = ingress_rule.port
        ip_protocol       = ingress_rule.protocol
        description       = ingress_rule.description
      }
    }
  ]...)
}
resource "aws_vpc_security_group_ingress_rule" "sg_ingress_rules" {
  for_each = local.ingress_rules

  security_group_id = each.value.security_group_id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  ip_protocol = each.value.ip_protocol
  description = each.value.description
}