# Human Tasks:
# 1. Ensure AWS credentials are properly configured with necessary permissions
# 2. Verify the S3 backend bucket exists and has versioning enabled
# 3. Review and adjust CIDR ranges based on network requirements
# 4. Configure environment-specific variables in a tfvars file
# 5. Ensure proper IAM roles and permissions are in place for EKS and RDS
# 6. Review and adjust resource sizing based on workload requirements

# Terraform configuration block
# Addresses requirement: Infrastructure Deployment
terraform {
  required_version = ">= 1.0.0"
  
  # AWS S3 backend for state management
  backend "s3" {
    bucket         = "spring-boot-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS Provider v4.0
      version = "~> 5.81"
    }
  }
}

# Local variables
locals {
  environment = var.environment
  common_tags = {
    Project     = "spring-boot-actuator"
    Environment = local.environment
    ManagedBy   = "terraform"
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Resource
# Addresses requirement: Infrastructure Deployment - Network Configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-${local.environment}-vpc"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-${local.environment}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                                          = "${var.app_name}-${local.environment}-public-${count.index + 1}"
      "kubernetes.io/role/elb"                      = "1"
      "kubernetes.io/cluster/${var.app_name}-${local.environment}" = "shared"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name                                          = "${var.app_name}-${local.environment}-private-${count.index + 1}"
      "kubernetes.io/role/internal-elb"             = "1"
      "kubernetes.io/cluster/${var.app_name}-${local.environment}" = "shared"
    }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = 2
  vpc   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-${local.environment}-nat-eip-${count.index + 1}"
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-${local.environment}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-${local.environment}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.app_name}-${local.environment}-private-rt-${count.index + 1}"
    }
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# EKS Module
# Addresses requirement: Infrastructure Deployment - Container Orchestration
module "eks" {
  source = "./modules/eks"

  vpc_id         = aws_vpc.main.id
  subnet_ids     = aws_subnet.private[*].id
  environment    = local.environment
  cluster_name   = "${var.app_name}-${local.environment}"
  cluster_version = "1.24"
  
  node_groups = {
    main = {
      desired_size = 2
      min_size     = 1
      max_size     = 4
      instance_types = ["t3.medium"]
    }
  }

  tags = local.common_tags
}

# RDS Module
# Addresses requirement: Infrastructure Deployment - Database Backend
module "rds" {
  source = "./modules/rds"

  vpc_id                 = aws_vpc.main.id
  subnet_ids             = aws_subnet.private[*].id
  environment           = local.environment
  database_name         = var.db_name
  instance_class        = "db.t3.medium"
  allocated_storage     = 20
  max_allocated_storage = 100
  engine_version        = "14.6"
  multi_az             = true
  backup_retention_period = 7
  database_username     = "dbadmin"
  database_password     = "CHANGE_ME_IN_SECRETS_MANAGER"
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.rds.db_instance_endpoint
}