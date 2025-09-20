variable "aws_region" {
  type = string
}

variable "vpc_id" {
  description = "VPC_ID"
  type = string 
}

variable "subnet_ids" {
  description = "SUBNET_ID"
  type = list(string)
}

variable "node_groups" {
  description = "NODE_GROUPS"
  type = map(any)
}

variable "cluster_name" {
  description = "CLUSTER_NAME"
  type = string
}
variable "cluster_version" {
  type = string
}
variable "secondary_cidr_block" {
  type = string
}

variable "secondary_subnets" {
  type = list
}

variable "zonal_shift_config_enabled" {
  type = bool
}

variable "cluster_addons" {
  type = map(any)
}
variable "create_asg_role" {
  type = bool
}

variable "access_cidrs" {
  type = list(string)
}