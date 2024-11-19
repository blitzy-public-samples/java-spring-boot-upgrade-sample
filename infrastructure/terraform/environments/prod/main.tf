# Human Tasks:
# 1. Ensure AWS credentials are properly configured for production environment
# 2. Verify S3 backend bucket exists with versioning enabled for production state
# 3. Review and adjust resource sizing based on production workload requirements
# 4. Ensure proper IAM roles and permissions are in place for production EKS and RDS
# 5. Verify multi-AZ deployment configurations for high availability
# 6. Review backup and retention policies for production data

# Terraform configuration block
# Addresses requirement: Production Infrastructure
terraform {
  required_version = ">= 1.0.0"
  
  # AWS S3 backend for production state management
  backend "s3" {
    bucket         = "spring-boot-terraform-state-prod"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock-prod"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS Provider v4.0
      version = "~> 4.0"
    }
  }
}

# Local variables for production environment
locals {
  environment = "prod"
  aws_region = "us-west-2"
  vpc_cidr = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  common_tags = {
    Environment = "production"
    Project     = "spring-boot-actuator"
    ManagedBy   = "terraform"
  }
}

# Root module configuration for production environment
# Addresses requirement: Production Infrastructure - High Availability and Scalability
module "main" {
  source = "../../"

  environment = local.environment
  aws_region  = local.aws_region
  vpc_cidr    = local.vpc_cidr
  app_name    = "spring-boot-actuator"
  db_name     = "springbootdb"

  # Production-grade EKS configuration with high availability
  eks_config = {
    cluster_version = "1.24"
    node_groups = {
      prod = {
        desired_size    = 3
        min_size       = 2
        max_size       = 5
        instance_types = ["t3.medium"]
      }
    }
  }

  # Production-grade RDS configuration with multi-AZ and automated backups
  rds_config = {
    instance_class           = "db.t3.medium"
    allocated_storage       = 50
    max_allocated_storage   = 100
    multi_az               = true
    backup_retention_period = 7
  }

  tags = local.common_tags
}

# Output values for production environment
output "vpc_id" {
  description = "Production VPC ID"
  value       = module.main.vpc_id
}

output "eks_cluster_endpoint" {
  description = "Production EKS cluster endpoint"
  value       = module.main.eks_cluster_endpoint
}

output "rds_endpoint" {
  description = "Production RDS endpoint"
  value       = module.main.rds_endpoint
}