# Requirement Addressed: Infrastructure Configuration
# Location: Technical Specification/Spring Boot Sample Tech Spec
# Description: Development environment specific values for infrastructure variables
# to support Spring Boot application deployment with EKS cluster and RDS database in AWS

# AWS Region Configuration
aws_region = "us-west-2"

# Environment Identifier
environment = "dev"

# Application Name
app_name = "spring-boot-actuator"

# VPC Configuration
vpc_cidr = "10.0.0.0/16"

# Subnet Configuration
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

# EKS Node Configuration
instance_type = "t3.medium"
min_nodes     = 2
max_nodes     = 3

# RDS Configuration
db_instance_class = "db.t3.micro"
db_name          = "springbootdb"