provider "aws" {
  region = local.default.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.95, <= 6.0.0"
    }
  }
    cloud { 
    
    organization = "kyo_devops_lab" 

    workspaces { 
      name = "for-dev" 
    } 
  } 
}