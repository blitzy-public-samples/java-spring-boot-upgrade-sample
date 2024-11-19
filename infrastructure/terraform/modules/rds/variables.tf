# Human Tasks:
# 1. Ensure AWS credentials are properly configured with permissions to create RDS instances
# 2. Review and adjust default values for production environments
# 3. Store sensitive variables (database_username, database_password) in a secure secrets management system
# 4. Verify VPC and subnet configurations meet RDS requirements (e.g., internet access for updates)

# Requirement Addressed: Database Configuration
# Location: Technical Specification/Spring Boot Application/Database Requirements
# Description: Defines variables needed for configuring the RDS instance that will replace 
# the H2 database used in the Spring Boot application

# Core networking variables
variable "vpc_id" {
  type        = string
  description = "ID of the VPC where RDS instance will be deployed"
  
  validation {
    condition     = length(var.vpc_id) > 0 && can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must be a valid AWS VPC identifier starting with 'vpc-'"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where RDS instance can be placed for high availability"
  
  validation {
    condition     = length(var.subnet_ids) >= 2 && alltrue([for s in var.subnet_ids : can(regex("^subnet-", s))])
    error_message = "At least two valid subnet IDs are required for RDS deployment, each starting with 'subnet-'"
  }
}

# Instance configuration variables
variable "instance_class" {
  type        = string
  description = "RDS instance class to use - must be compatible with PostgreSQL"
  default     = "db.t3.micro"
  
  validation {
    condition     = can(regex("^db\\.(t3|t4g|m5|r5)\\.", var.instance_class))
    error_message = "Instance class must be a valid RDS instance type"
  }
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage size in GB"
  default     = 20
  
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 16384
    error_message = "Allocated storage must be between 20 and 16384 GB"
  }
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum storage size in GB for autoscaling"
  default     = 100
  
  validation {
    condition     = var.max_allocated_storage >= var.allocated_storage
    error_message = "Maximum allocated storage must be greater than or equal to allocated storage"
  }
}

# Database configuration variables
variable "database_name" {
  type        = string
  description = "Name of the PostgreSQL database to create for Spring Boot application"
  default     = "spring_boot_db"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores"
  }
}

variable "database_username" {
  type        = string
  description = "Master username for the PostgreSQL database instance"
  sensitive   = true
  
  validation {
    condition     = length(var.database_username) >= 1 && length(var.database_username) <= 63 && can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.database_username))
    error_message = "Username must be 1-63 characters long, start with a letter, and contain only alphanumeric characters and underscores"
  }
}

variable "database_password" {
  type        = string
  description = "Master password for the PostgreSQL database instance"
  sensitive   = true
  
  validation {
    condition     = length(var.database_password) >= 8 && can(regex("[A-Z]", var.database_password)) && can(regex("[a-z]", var.database_password)) && can(regex("[0-9]", var.database_password)) && can(regex("[^a-zA-Z0-9]", var.database_password))
    error_message = "Password must be at least 8 characters and contain uppercase, lowercase, numbers and special characters"
  }
}

# Backup and high availability configuration
variable "backup_retention_period" {
  type        = number
  description = "Number of days to retain automated backups"
  default     = 7
  
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days"
  }
}

variable "multi_az" {
  type        = bool
  description = "Whether to enable Multi-AZ deployment for high availability"
  default     = false
}

# Environment and version configuration
variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod) that determines RDS configuration settings"
  
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either dev or prod"
  }
}

variable "engine_version" {
  type        = string
  description = "PostgreSQL engine version for RDS"
  default     = "13.7"
  
  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.engine_version))
    error_message = "Must be a valid PostgreSQL version number (e.g. 13.7)"
  }
}