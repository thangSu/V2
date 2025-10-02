variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}
variable "subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = map(any)
}

variable "aws_region" {
  description = "AWS region where the VPC will be created"
  type        = string
}
variable "secondary_subnet_cidr_blocks" {
  description = "List of secondary CIDR blocks for the VPC"
  type        = list(string)
}
variable "secondary_cidr_blocks" {
  description = "values for secondary CIDR blocks"
  type        = string
  default     = ""
}

variable "create_nat_gateway" {
  type = bool
  default = false
}

variable "project-name" {
  type = string
}

variable "route_tables" {
  type = list(string)
}