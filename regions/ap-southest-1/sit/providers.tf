provider "aws" {
  region = local.default.aws_region
}

terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.66"
    }
  }
    cloud { 
    
    organization = "kyo_devops_lab" 

    workspaces { 
      name = "for-dev" 
    } 
  } 
}