# Required providers configuration for AWS and Kubernetes
# Addresses requirement: Infrastructure Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS Provider v4.0
      version = "~> 5.81"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"  # Kubernetes Provider v2.0
      version = "~> 2.0"
    }
  }
}

# AWS provider configuration for managing cloud infrastructure resources
provider "aws" {
  region  = "us-west-2"  # Default region for AWS resources
  profile = "default"    # AWS credentials profile to use
  
  # Additional recommended settings
  default_tags {
    tags = {
      Environment = "production"
      ManagedBy  = "terraform"
      Project    = "spring-boot-sample"
    }
  }
}

# Kubernetes provider configuration for managing K8s resources
provider "kubernetes" {
  # Kubernetes cluster configuration
  host = data.aws_eks_cluster.cluster.endpoint
  
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                 = data.aws_eks_cluster_auth.cluster.token
  
  # Recommended settings for production
  experiments {
    manifest_resource = true
  }
}

# Data sources for EKS cluster authentication
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

# Human Tasks:
# 1. Ensure AWS credentials are properly configured in ~/.aws/credentials or via environment variables
# 2. Configure the appropriate AWS region based on deployment requirements
# 3. Set up EKS cluster and ensure proper IAM roles/permissions are in place
# 4. Verify network connectivity between Terraform execution environment and EKS cluster
# 5. Review and adjust default tags according to organization's tagging strategy