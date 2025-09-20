##########################
# Cluster Managed Addon   #
##########################
locals {
  managed_addons = {
    vpc-cni = {
      before_compute           = true
      addon_version            = var.cluster_addons.vpc_cni_addon_version
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        # ENI Configuration for Secondary CIDR
        eniConfig = {
          create  = true
          region  = var.aws_region
          subnets = { for subnet in var.secondary_subnets : subnet.availability_zone => { "id" : subnet.id } }
        }
        env = {
          # Reference https://aws.github.io/aws-eks-best-practices/reliability/docs/networkmanagement/#cni-custom-networking
          AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
          ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    coredns = {
      addon_version = var.cluster_addons.coredns_addon_version
      configuration_values = jsonencode({
        "tolerations" : [
          {
            "operator" : "Exists"
          }
        ]
      })
    }
    kube-proxy = {
      addon_version = var.cluster_addons.kube_proxy_addon_version
    }
    # eks-pod-identity-agent = {
    # }
    # aws-ebs-csi-driver = {
    #   addon_version            = var.cluster_addons.aws_ebs_csi_driver_addon_version
    #   service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    #   configuration_values = jsonencode({
    #     "controller" : {
    #       "tolerations" : [
    #         {
    #           "key" : "dedicated",
    #           "operator" : "Equal",
    #           "value" : "infra",
    #           "effect" : "NoSchedule"
    #         }
    #       ],
    #       "nodeSelector" : {
    #         "type" : "infra"
    #       },
    #       "extraVolumeTags" : {
    #         "map-migrated" : "mig45206"
    #       }
    #     }
    #   })
    # }
    # aws-efs-csi-driver = {
    #   addon_version            = var.cluster_addons.aws_efs_csi_driver_addon_version
    #   service_account_role_arn = module.efs_csi_driver_irsa.iam_role_arn
    #   configuration_values = jsonencode({
    #     "controller" : {
    #       "tolerations" : [
    #         {
    #           "key" : "dedicated",
    #           "operator" : "Equal",
    #           "value" : "infra",
    #           "effect" : "NoSchedule"
    #         }
    #       ],
    #       "nodeSelector" : {
    #         "type" : "infra"
    #       },
    #     }
    #   })
    # }
  }
}
