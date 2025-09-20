module "eks_kms_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  context    = module.this.context
  attributes = ["kms", "eks"]
}
# resource "aws_iam_service_linked_role" "autoscaling" {
#   count = var.create_asg_role && length(data.aws_iam_service_linked_role.autoscaling.arn) == 0 ? 1 : 0

#   aws_service_name = "autoscaling.amazonaws.com"
#   tags             = module.eks_kms_label.tags
# }
module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"
  # Aliases
  aliases_use_name_prefix = false

  key_service_roles_for_autoscaling = [
    # required for the ASG to manage encrypted volumes for nodes
    format("arn:aws:iam::%s:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling", data.aws_caller_identity.current.account_id),
    # required for the cluster / persistentvolume-controller to create encrypted PVCs
    module.eks.cluster_iam_role_arn,
  ]
  description = "Customer managed key to encrypt EKS managed node group volumes"

  #depends_on = [aws_iam_service_linked_role.autoscaling]

}