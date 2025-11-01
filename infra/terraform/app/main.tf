############################################################
# Global Data and Locals
############################################################

#terraform {
  backend "s3" {
    bucket         = "techv-tfstate-global"
    key            = "techv/app.tfstate"
    region         = "us-west-2"
    dynamodb_table = "techv-tfstate-lock"
  }
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  caller_arn  = data.aws_caller_identity.current.arn
  caller_name = try(
    regex("arn:aws:iam::\\d+:user/(.+)", local.caller_arn)[0],
    regex("arn:aws:iam::\\d+:assumed-role/[^/]+/(.+)", local.caller_arn)[0],
    "unknown-user"
  )
}

############################################################
# EKS Cluster References
############################################################
############################################################
# Apply aws-auth ConfigMap (gives kubectl admin access)
############################################################
#resource "kubernetes_config_map_v1" "aws_auth" {
 # metadata {
 #   name      = "aws-auth"
 #   namespace = "kube-system"
 # }

#  data = {
#    mapUsers = yamlencode([
#      {
#        userarn  = local.caller_arn
#        username = local.caller_name
#        groups   = ["system:masters"]
#      }
#    ])
#  }

#  depends_on = [
#    null_resource.wait_for_cluster,
    #aws_eks_access_entry.current_user
#  ]
#}
