module "ebs_csi_driver_iam_policy_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["iam-policy", "ebs-csi-driver"]
}
module "ebs_csi_driver_irsa_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["irsa", "ebs-csi-driver"]
}
module "alb_controller_irsa_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["irsa", "alb-controller"]
}
module "cluster_autoscaler_irsa_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["irsa", "cluster-autoscaler"]
}
module "vpc_cni_irsa_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["irsa", "vpc-cni"]
}
#########################
# IRSA For EBS CSI Addon #
##########################
module "ebs_csi_driver_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.54.0"
  name        = module.ebs_csi_driver_iam_policy_label.id
  path        = "/"
  description = "EBS CSI Driver policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = module.kms.key_arn
      }
    ]
  })
  tags = module.this.tags
}
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name = module.ebs_csi_driver_irsa_label.id

  attach_ebs_csi_policy = true

  role_policy_arns = {
    policy = module.ebs_csi_driver_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = module.ebs_csi_driver_irsa_label.tags
  
}
#########################
# IRSA For ALB Addon #
##########################
module "aws_loadbalancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name                              = module.alb_controller_irsa_label.id
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller-sa"]
    }
  }

  tags = module.alb_controller_irsa_label.tags
}
############################
# IRSA For Cluster Autoscaler #
############################
module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name                        = module.cluster_autoscaler_irsa_label.id
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks_cluster_label.id]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler-sa"]
    }
  }

  tags = module.cluster_autoscaler_irsa_label.tags
}
#########################
# IRSA For VPC CNI Addon #
##########################
module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.54.0"

  role_name     = module.vpc_cni_irsa_label.id
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = module.vpc_cni_irsa_label.tags
}
