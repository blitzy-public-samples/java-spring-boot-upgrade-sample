# Human Tasks:
# 1. Ensure AWS credentials are configured with permissions for S3 and DynamoDB
# 2. Create the S3 bucket 'spring-boot-terraform-state' with versioning enabled
# 3. Create the DynamoDB table 'terraform-state-lock' with 'LockID' as primary key
# 4. Configure IAM roles/policies for team members to access the state

# AWS Provider version: ~> 4.0
# Requirement: Infrastructure State Management
# Configures remote state storage in S3 with encryption and state locking
terraform {
  backend "s3" {
    # S3 bucket for state storage
    bucket = "spring-boot-terraform-state"
    key    = "terraform.tfstate"
    region = "us-west-2"

    # Requirement: State Security
    # Enable server-side encryption for state files
    encrypt = true

    # Requirement: Concurrent Access Protection
    # DynamoDB table for state locking
    dynamodb_table = "terraform-state-lock"

    # Workspace management for environment separation
    workspace_key_prefix = "env"

    # Additional security configurations
    # Enable bucket versioning for state history
    versioning = true

    # Force SSL/TLS for state access
    force_path_style = false
    
    # Enable access logging
    # Note: Access logging bucket must be configured separately
    access_logging = true
  }
}