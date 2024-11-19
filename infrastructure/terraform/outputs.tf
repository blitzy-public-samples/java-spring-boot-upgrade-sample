# Terraform outputs configuration for infrastructure components
# Addresses requirement: Infrastructure Output Values
# Location: Technical Specification/Infrastructure Requirements
# Description: Exposes critical access information from EKS cluster and RDS database 
# for use by the Spring Boot application and other infrastructure components

# EKS Cluster Outputs
output "cluster_endpoint" {
  description = "The endpoint URL of the EKS cluster"
  value       = module.eks.cluster_endpoint
  sensitive   = false
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
  sensitive   = false
}

output "cluster_certificate" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = false
}

# RDS Database Outputs
output "db_endpoint" {
  description = "The connection endpoint for the RDS database"
  value       = module.rds.db_instance_endpoint
  sensitive   = false
}

output "db_name" {
  description = "The name of the RDS database"
  value       = module.rds.db_instance_name
  sensitive   = false
}

output "db_port" {
  description = "The port number for the RDS database"
  value       = module.rds.db_instance_port
  sensitive   = false
}