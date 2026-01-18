# Minimal EKS cluster (placeholder) - fill in with real config as needed
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  # pin to a known-working module release that accepts these arguments
  version         = "20.11.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.34"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Managed node group example - adjust sizing and instance types for your workload
  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
      # add tags specific to node group
      tags = {
        Name = "${var.cluster_name}-nodes"
      }
      # use a dedicated IAM role created below
      iam_role_arn = aws_iam_role.eks_node_role.arn
    }
  }

  # API server access and logging
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  # enable control plane logging (safe defaults)
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Helpful tags propagated to created resources
  tags = merge({
    Name = var.cluster_name
    Project = var.cluster_name
  }, {}
  )

  # Optionally enable IAM Roles for Service Accounts (IRSA)
  # enable_irsa = true
  # Grant the cluster creator (the identity running Terraform) admin permissions
  enable_cluster_creator_admin_permissions = true
}


### IAM: Node group role
resource "aws_iam_role" "eks_node_role" {
  name               = "${var.cluster_name}-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
  tags = {
    Project = var.cluster_name
    Name    = "${var.cluster_name}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

