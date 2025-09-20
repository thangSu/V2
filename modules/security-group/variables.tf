variable "security_groups" {
  description = "The list of Security Group"
  type        = map(any)
}
variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

