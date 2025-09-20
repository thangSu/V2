output "security_group_ids" {
  value = { for key, sg in module.security_groups : key => sg.security_group_id }
}
