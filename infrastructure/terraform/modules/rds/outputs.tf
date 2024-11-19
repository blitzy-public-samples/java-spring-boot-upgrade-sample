# Requirement Addressed: Database Infrastructure
# Location: Technical Specification/Infrastructure
# Description: Output definitions for RDS database infrastructure that expose 
# critical connection parameters and resource identifiers needed by the Spring Boot application

# Connection endpoint for database access
output "db_instance_endpoint" {
  description = "The connection endpoint URL for the RDS instance"
  value       = aws_db_instance.main.endpoint
}

# Unique identifier for the RDS instance
output "db_instance_id" {
  description = "The identifier of the RDS instance"
  value       = aws_db_instance.main.id
}

# Standard PostgreSQL port number
output "db_instance_port" {
  description = "The port number on which the RDS instance accepts connections"
  value       = 5432
}

# Database instance name for application configuration
output "db_instance_name" {
  description = "The name of the database instance"
  value       = aws_db_instance.main.db_name
}

# Security group ID for network configuration
output "db_security_group_id" {
  description = "The ID of the security group associated with the RDS instance"
  value       = aws_security_group.rds.id
}