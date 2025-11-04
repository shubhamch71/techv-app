# Admin IAM user for laptop access (AdministratorAccess)
resource "aws_iam_user" "admin" {
  name = "${var.cluster_name}-admin"
  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "admin_attach" {
  user       = aws_iam_user.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create access key for admin (sensitive output)
resource "aws_iam_access_key" "admin_key" {
  user = aws_iam_user.admin.name
}

# Security group for EKS nodes (workers)
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.tags, { Name = "${var.cluster_name}-eks-node-sg" })
}

