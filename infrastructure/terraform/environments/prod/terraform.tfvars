# Production Environment Terraform Variable Definitions
# Requirement Addressed: Production Infrastructure Configuration
# Location: Technical Specification/Infrastructure Requirements
# Description: Defines production-specific values for infrastructure variables to support 
# the Spring Boot application deployment with high availability, scalability, and security requirements

# Core Infrastructure Settings
aws_region = "us-west-2"
environment = "prod"
app_name = "spring-boot-actuator"

# Networking Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = [
  "10.0.1.0/24",  # us-west-2a
  "10.0.2.0/24"   # us-west-2b
]
private_subnet_cidrs = [
  "10.0.3.0/24",  # us-west-2a
  "10.0.4.0/24"   # us-west-2b
]

# EKS Cluster Configuration
instance_type = "t3.large"
min_nodes = 3
max_nodes = 10
cluster_version = "1.27"

# RDS Database Configuration
db_instance_class = "db.t3.large"
db_name = "springbootdb_prod"
multi_az = true
backup_retention_period = 30