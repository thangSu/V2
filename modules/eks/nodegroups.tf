locals {
  eks_managed_nodegroups = {
    for key, node_group in var.node_groups :
    key => {
      name                 = node_group.name
      launch_template_name = node_group.name
      instance_types       = node_group.instance_types
      capacity_type        = node_group.capacity_type
      # Bottlerocket enabled
      ami_type = node_group.ami_type
      platform = node_group.platform
      # Scaling Config
      desired_size = node_group.desired_size
      max_size     = node_group.max_size
      min_size     = node_group.min_size
      labels       = node_group.labels
      taints       = node_group.taints
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda" #OS Volume
          ebs = {
            volume_size           = 30
            volume_type           = "gp3"
            iops                  = 3000
            throughput            = 125
            encrypted             = true
            #kms_key_id            = module.kms.key_arn
            delete_on_termination = true
          }
        }
      }
      #vpc_security_group_ids = node_group.security_group_ids
      subnet_ids             = node_group.subnet_ids
    }
  }
}
