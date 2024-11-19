# Human Tasks:
# 1. Ensure AWS credentials are properly configured for development environment
# 2. Review and adjust CIDR ranges if they conflict with existing networks
# 3. Verify development environment resource sizes are appropriate for workload
# 4. Configure environment-specific variables in dev.tfvars file
# 5. Ensure proper IAM roles and permissions are in place for EKS and RDS

# Terraform configuration block
# Addresses requirement: Development Infrastructure
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS Provider v4.0
      version = "~> 4.0"
    }
  }
}

# Local variables for development environment
locals {
  environment = "dev"
  aws_region = "us-west-2"
  tags = {
    Environment = "dev"
    Project     = "spring-boot-actuator"
    ManagedBy   = "terraform"
  }
}

# Root module implementation for development environment
# Addresses requirement: Development Infrastructure - Configures development-specific infrastructure
module "root" {
  source = "../../"

  # Core configuration
  aws_region  = local.aws_region
  environment = local.environment
  app_name    = "spring-boot-actuator"

  # Network configuration
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

  # Development-sized compute resources
  instance_type = "t3.medium"
  min_nodes     = 2
  max_nodes     = 3

  # Development-sized database resources
  db_instance_class = "db.t3.micro"
  db_name          = "springbootdb"

  tags = local.tags
}

# Outputs for development environment
output "vpc_id" {
  description = "VPC ID created for dev environment"
  value       = module.root.vpc_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint for dev environment"
  value       = module.root.eks_cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS database endpoint for dev environment"
  value       = module.root.rds_endpoint
}