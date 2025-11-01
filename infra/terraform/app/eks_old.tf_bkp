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
  # AUTOMATICALLY INSTALL ADDONS
  # --------------------------------------------------
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
      # Optional: Pin version
      # resolve_conflicts = "OVERWRITE"
    }

    eks-pod-identity-agent = {
      most_recent = true
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
      echo "EKS cluster is ACTIVE"
    EOT
    interpreter = ["bash", "-c"]
  }
}

# ------------------------------------------------------------
# Wait for Addons to be Installed
# ------------------------------------------------------------
resource "null_resource" "wait_for_addons" {
  depends_on = [module.eks_cluster, null_resource.wait_for_cluster]

  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for EBS CSI Driver and Pod Identity Agent to be ACTIVE..."

      # Wait for EBS CSI Driver
      until kubectl get daemonset ebs-csi-controller -n kube-system --kubeconfig <(aws eks update-kubeconfig --name ${module.eks_cluster.cluster_name} --region ${var.region} - <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${module.eks_cluster.cluster_endpoint}
    certificate-authority-data: ${module.eks_cluster.cluster_certificate_authority_data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${module.eks_cluster.cluster_name}"
        - "--region"
        - "${var.region}"
EOF
) > /dev/null 2>&1; do
        echo "ebs-csi-controller not ready... sleeping 10s"
        sleep 10
      done

      # Wait for Pod Identity Agent
      until kubectl get daemonset aws-pod-identity-webhook -n kube-system --kubeconfig <(aws eks update-kubeconfig --name ${module.eks_cluster.cluster_name} --region ${var.region} - <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    server: ${module.eks_cluster.cluster_endpoint}
    certificate-authority-data: ${module.eks_cluster.cluster_certificate_authority_data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${module.eks_cluster.cluster_name}"
        - "--region"
        - "${var.region}"
EOF
) > /dev/null 2>&1; do
        echo "aws-pod-identity-webhook not ready... sleeping 10s"
        sleep 10
      done

      echo "All addons installed and running!"
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
# Automatically update kubeconfig
# ------------------------------------------------------------
resource "null_resource" "update_kubeconfig" {
  depends_on = [null_resource.wait_for_addons]  # Wait for addons too

  provisioner "local-exec" {
    command = <<EOT
      echo "Updating kubeconfig..."
      aws eks update-kubeconfig \
        --name ${module.eks_cluster.cluster_name} \
        --region ${var.region}
      echo "Kubeconfig updated. Run: kubectl get nodes"
    EOT
    interpreter = ["bash", "-c"]
  }
}

# Optional: Verify addons
output "ebs_csi_driver_status" {
  value = "Installed via cluster_addons"
}

output "pod_identity_agent_status" {
  value = "Installed via cluster_addons"
}
