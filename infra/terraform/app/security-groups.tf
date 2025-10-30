##############################################################
# SECURITY GROUP – EKS Nodes + Application
##############################################################

resource "aws_security_group" "eks_app_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for EKS worker nodes and application traffic"
  vpc_id      = module.vpc.vpc_id

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (optional - remove if not needed)
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (frontend/backend)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow NodePort Services
  ingress {
    description = "Allow NodePort range"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-sg"
  }
}

##############################################################
# OUTPUTS
##############################################################

output "app_security_group_id" {
  description = "Security group ID used by EKS"
  value       = aws_security_group.eks_app_sg.id
}
