# Human Tasks:
# 1. Review and adjust default values based on environment requirements
# 2. Ensure sensitive variables (db_username, db_password) are managed securely
# 3. Verify CIDR ranges align with network architecture
# 4. Validate instance types meet performance requirements
# 5. Configure environment-specific values in separate tfvars files

# Requirement Addressed: Infrastructure Configuration
# Location: Technical Specification/Infrastructure Requirements
# Description: Defines configurable variables for infrastructure deployment

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # AWS Provider v4.0
      version = "~> 5.80"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "app_name" {
  type        = string
  description = "Name of the Spring Boot application"
  default     = "spring-boot-actuator"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block"
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnet CIDRs are required for high availability"
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnet CIDRs are required for high availability"
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for EKS nodes"
  default     = "t3.medium"

  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge"], var.instance_type)
    error_message = "Instance type must be one of: t3.medium, t3.large, t3.xlarge"
  }
}

variable "min_nodes" {
  type        = number
  description = "Minimum number of EKS nodes"
  default     = 2

  validation {
    condition     = var.min_nodes >= 2
    error_message = "Minimum number of nodes must be at least 2 for high availability"
  }
}

variable "max_nodes" {
  type        = number
  description = "Maximum number of EKS nodes"
  default     = 5

  validation {
    condition     = var.max_nodes >= var.min_nodes
    error_message = "Maximum nodes must be greater than or equal to minimum nodes"
  }
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.t3.micro"

  validation {
    condition     = contains(["db.t3.micro", "db.t3.small", "db.t3.medium"], var.db_instance_class)
    error_message = "DB instance class must be one of: db.t3.micro, db.t3.small, db.t3.medium"
  }
}

variable "db_name" {
  type        = string
  description = "Name of the database"
  default     = "springbootdb"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores"
  }
}

variable "db_username" {
  type        = string
  description = "Database master username"
  sensitive   = true

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores"
  }
}

variable "db_password" {
  type        = string
  description = "Database master password"
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "Database password must be at least 8 characters long"
  }
}