resource "aws_eks_cluster" "main" {
  name     = "my-cluster"
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Auto Mode
  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node.arn
  }
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "workers"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = ["m5.large", "c5.xlarge"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
}

resource "aws_launch_template" "al2023" {
  name = "eks-al2023-node"

  user_data = base64encode(<<-EOF
    #!/bin/bash
    /opt/nodeadm/bin/nodeadm init --apiserver-endpoint ${aws_eks_cluster.main.endpoint} --cluster-name ${aws_eks_cluster.main.name}
  EOF
  )
}

resource "aws_iam_role" "cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "node" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

variable "subnet_ids" {
  type = list(string)
}
