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

  # ✅ This automatically grants your Terraform IAM user full admin rights
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      desired_size   = var.node_desired_size
      max_size       = var.node_max_size
      min_size       = var.node_min_size
      additional_security_group_ids = [aws_security_group.eks_app_sg.id]
    }
  }

  tags = merge(var.tags, { Name = var.cluster_name })
}

# ------------------------------------------------------------
# Wait for EKS cluster to become ACTIVE
# ------------------------------------------------------------
resource "null_resource" "wait_for_cluster" {
  depends_on = [module.eks_cluster]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EKS cluster '${module.eks_cluster.cluster_name}' to be ACTIVE..."
      until aws eks describe-cluster \
        --name ${module.eks_cluster.cluster_name} \
        --region ${var.region} \
        --query 'cluster.status' \
        --output text 2>/dev/null | grep -q "ACTIVE"; do
        echo "Cluster not ready yet... sleeping 15s"
        sleep 15
      done
      echo "✅ EKS cluster is ACTIVE"
    EOT
    interpreter = ["bash", "-c"]
  }
}

# ------------------------------------------------------------
# Fetch cluster details AFTER creation
# ------------------------------------------------------------
data "aws_eks_cluster" "this" {
  depends_on = [null_resource.wait_for_cluster]
  name       = module.eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [null_resource.wait_for_cluster]
  name       = module.eks_cluster.cluster_name
}

# ------------------------------------------------------------
# Automatically update kubeconfig so you can access from laptop
# ------------------------------------------------------------
resource "null_resource" "update_kubeconfig" {
  depends_on = [data.aws_eks_cluster.this]

  provisioner "local-exec" {
    command = <<EOT
      echo "🔧 Updating kubeconfig..."
      aws eks update-kubeconfig \
        --name ${module.eks_cluster.cluster_name} \
        --region ${var.region}
      echo "✅ Kubeconfig updated. You can now run 'kubectl get nodes'"
    EOT
    interpreter = ["bash", "-c"]
  }
}

#resource "aws_eks_access_entry" "current_user" {
#  cluster_name  = module.eks_cluster.cluster_name
#  principal_arn = local.caller_arn
#  type          = "STANDARD"
#}
