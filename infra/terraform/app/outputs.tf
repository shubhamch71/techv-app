output "eks_cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  value     = module.eks_cluster.cluster_certificate_authority_data
  sensitive = true
}

output "admin_iam_user_name" {
  value = aws_iam_user.admin.name
}

output "admin_iam_user_access_key_id" {
  value     = aws_iam_access_key.admin_key.id
  sensitive = true
}

output "admin_iam_user_secret_access_key" {
  value     = aws_iam_access_key.admin_key.secret
  sensitive = true
}
