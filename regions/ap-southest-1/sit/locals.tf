locals {
  default = {
    aws_region = "ap-southeast-1"
    env    = "sit"
    namespace = "tp"
    stage = "sit"
    name = "devops"
    account = "123456789012"
    tags = {
      Environment = "sit"
      Project     = "devops"
      Owner       = "thangpn"
      BusinessUnit = "XYZ"
      Account_id = "123456789012"
      Aws_Region = "ap-southeast-1"
    }
  }

  eks = {
    cluster_name = "dev-project-sit-eks"
    cluster_version = "1.33"
    zonal_shift_config_enabled = true
    create_iam_role = true
    create_asg_role = true
    addons = {
      vpc_cni_addon_version            = "v1.19.6-eksbuild.1"
      # aws_ebs_csi_driver_addon_version = "v1.44.0-eksbuild.1"
      # aws_efs_csi_driver_addon_version = "v2.1.8-eksbuild.1"
      coredns_addon_version            = "v1.12.1-eksbuild.2"
      kube_proxy_addon_version         = "v1.33.0-eksbuild.2"
    }
    node_groups = {
      infra-node = {
        name           = "infra-node"
        instance_types = ["t3.medium"]
        capacity_type  = "ON_DEMAND"
        # Bottlerocket enabled
        ami_type = "AL2023_x86_64_STANDARD"
        platform = "al2023"
        # Scaling Config
        desired_size = 1
        max_size     = 5
        min_size     = 1
        labels = {
          type = "infra"
        }
        taints = [
          {
            key    = "dedicated"
            value  = "infra"
            effect = "NO_SCHEDULE"
          }
        ]
        subnet_ids         = local.app_subnet_ids
        #security_group_ids = [module.security_group.security_group_ids["eks-security-groups"]]
      }
      workload-node = {
        name           = "workload-node"
        instance_types = ["t3.medium"]
        capacity_type  = "ON_DEMAND"
        # Bottlerocket enabled
        ami_type = "AL2023_x86_64_STANDARD"
        platform = "al2023"
        # Scaling Config
        desired_size = 1
        max_size     = 3
        min_size     = 1
        labels = {
          type = "workload"
        }
        taints = [
          {
            key    = "dedicated"
            value  = "workload"
            effect = "NO_SCHEDULE"
          }
        ]
        subnet_ids         = local.app_subnet_ids
        # security_group_ids = [module.security_group.security_group_ids[module.eks_node_temporal_sg_label.id]]
      }
    }
  }
  network = {
    vpc_name = "dev-project-sit-vpc"
    vpc_cidr = "10.10.0.0/16"
    create_nat_gateway = true

    subnets = {
      public = {
        public-subnet-1a = {
          availability_zone = "ap-southeast-1a"
          cidr_block = "10.10.11.0/24"
          route_table = "public"
        }
        public-subnet-1b = {
          availability_zone = "ap-southeast-1b"
          cidr_block = "10.10.12.0/24"
          route_table = "public"
        }
        public-subnet-1c = {
          availability_zone = "ap-southeast-1c"
          cidr_block = "10.10.13.0/24"
          route_table = "public"
        }
      }
      app = {
        app_subnet_1a = {
          availability_zone = "ap-southeast-1a"
          cidr_block = "10.10.51.0/24"
          route_table = "app"
        }
        app_subnet_1b = {
          availability_zone = "ap-southeast-1b"
          cidr_block = "10.10.52.0/24"
          route_table = "app"
        }
        app_subnet_1c = {
          availability_zone = "ap-southeast-1c"
          cidr_block = "10.10.53.0/24"
          route_table = "app"
        }
      }
      data = {
        data-subnet-1a = {
          availability_zone = "ap-southeast-1a"
          cidr_block = "10.10.101.0/24"
          route_table = "data"
        }
        data-subnet-1b = {
          availability_zone = "ap-southeast-1b"
          cidr_block = "10.10.102.0/24"
          route_table = "data"
        }
        data-subnet-1c = {
          availability_zone = "ap-southeast-1c"
          cidr_block = "10.10.103.0/24"
          route_table = "data"
        }
      }
    }
    route_tables = ["public", "app", "data"]
    secondary_cidr_block = "100.10.0.0/20"
    secondary_subnets = ["100.10.0.0/23", "100.10.2.0/23", "100.10.4.0/23"]
    load_balancer_type = "elb"
  }
}