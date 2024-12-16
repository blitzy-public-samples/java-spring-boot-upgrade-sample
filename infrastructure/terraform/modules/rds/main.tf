# Human Tasks:
# 1. Ensure AWS credentials are properly configured with appropriate RDS permissions
# 2. Verify VPC and subnet configurations meet RDS requirements (private subnets with NAT gateway)
# 3. Configure AWS Secrets Manager or SSM Parameter Store for database credentials
# 4. Review backup windows and maintenance windows align with application SLAs
# 5. Ensure monitoring IAM roles are properly set up for Enhanced Monitoring

# AWS Provider configuration
# AWS Provider version ~> 4.0
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81"
    }
  }
}

# Local variables
locals {
  db_port = 5432
}

# Requirement Addressed: Database Backend
# Location: Technical Specification/Spring Boot Application/Database Configuration
# Description: Data source to fetch VPC details for security group configuration
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Requirement Addressed: Database Backend
# Location: Technical Specification/Spring Boot Application/Database Configuration
# Description: RDS subnet group for high availability across multiple AZs
resource "aws_db_subnet_group" "rds" {
  name        = "${var.environment}-spring-boot-subnet-group"
  subnet_ids  = var.subnet_ids
  
  tags = {
    Name        = "${var.environment}-spring-boot-rds-subnet-group"
    Environment = var.environment
  }
}

# Requirement Addressed: Database Backend
# Location: Technical Specification/Spring Boot Application/Database Configuration
# Description: Security group for RDS instance with proper access controls
resource "aws_security_group" "rds" {
  name        = "${var.environment}-spring-boot-rds-sg"
  description = "Security group for Spring Boot RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL access from VPC"
    from_port   = local.db_port
    to_port     = local.db_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-spring-boot-rds-sg"
    Environment = var.environment
  }
}

# Requirement Addressed: Database Backend
# Location: Technical Specification/Spring Boot Application/Database Configuration
# Description: RDS PostgreSQL instance with production-grade configurations
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-spring-boot-db"
  engine         = "postgres"
  engine_version = var.engine_version
  
  instance_class        = var.instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = true
  
  db_name  = var.database_name
  username = var.database_username
  password = var.database_password
  
  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = var.backup_retention_period
  backup_window          = "02:00-03:00"
  maintenance_window     = "Mon:03:00-Mon:04:00"
  
  skip_final_snapshot    = false
  final_snapshot_identifier = "${var.environment}-spring-boot-db-final"
  
  performance_insights_enabled = true
  monitoring_interval         = 60
  
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]
  
  tags = {
    Name        = "${var.environment}-spring-boot-rds"
    Environment = var.environment
  }
}

# Output values for use by other modules or the root module
output "db_instance_endpoint" {
  description = "Connection endpoint URL of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "Identifier of the RDS instance"
  value       = aws_db_instance.main.id
}

output "db_instance_port" {
  description = "Port number of the RDS instance"
  value       = local.db_port
}