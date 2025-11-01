terraform {
  required_version = ">= 1.5.0"

  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.97.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

# AWS Provider
provider "aws" {
  region = var.region
}

# Kubernetes Provider (will connect after EKS creation)
provider "kubernetes" {
  host                   = try(data.aws_eks_cluster.this.endpoint, "")
  cluster_ca_certificate = try(base64decode(data.aws_eks_cluster.this.certificate_authority[0].data), "")
  token                  = try(data.aws_eks_cluster_auth.this.token, "")
}

# EKS Cluster Data Sources

