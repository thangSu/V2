module "vpc_cni_irsa_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["irsa", "vpc-cni"]
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

resource "aws_iam_role" "vpc_cni_irsa" {
  name = "alb-controller"

  assume_role_policy = templatefile("${path.module}/addon_policies/irsa_assume_policy.json", {
    account_id               = data.aws_caller_identity.current.account_id
    oidc_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
    service_account_namespace = "kube-system"
    service_account_name      = "aws-node"
  })
}

resource "aws_iam_role_policy_attachment" "vpc_cni_irsa" {
  role       = aws_iam_role.vpc_cni_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}