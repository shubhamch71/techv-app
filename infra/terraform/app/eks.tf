# ------------------------------------------------------------
# EKS Cluster Module
# ------------------------------------------------------------
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access = true

  # Grants Terraform IAM user full admin rights
  enable_cluster_creator_admin_permissions = true

  # --------------------------------------------------
  # EKS Managed Node Group
  # --------------------------------------------------
  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      min_size       = var.node_min_size
      additional_security_group_ids = [aws_security_group.eks_app_sg.id]
    }
  }

  # --------------------------------------------------
  # NO ADDONS — INSTALLED VIA CLI IN GITHUB ACTIONS
  # --------------------------------------------------
}

# ------------------------------------------------------------
# Fetch cluster details AFTER creation
# ------------------------------------------------------------
data "aws_eks_cluster" "this" {
  name = module.eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_cluster.cluster_name
}

# ------------------------------------------------------------
# Output cluster name
# ------------------------------------------------------------
output "cluster_name" {
  value = module.eks_cluster.cluster_name
}