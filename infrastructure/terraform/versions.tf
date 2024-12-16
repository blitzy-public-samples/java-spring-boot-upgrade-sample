# Terraform version constraints and provider requirements
# Addresses requirement: Infrastructure Version Control
# This file ensures consistent versioning across all infrastructure components

terraform {
  # Specify the minimum required version of Terraform
  # Using ~> 1.0 ensures compatibility with 1.x versions while preventing breaking changes
  required_version = "~> 1.0"

  # Define required providers and their version constraints
  required_providers {
    # AWS Provider for managing cloud infrastructure
    # Version ~> 4.0 provides stability while allowing minor version updates
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81"
    }

    # Kubernetes Provider for container orchestration
    # Version ~> 2.0 ensures compatibility with modern Kubernetes features
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Human Tasks:
# 1. Verify that the local Terraform installation meets the required version constraint (~> 1.0)
# 2. Ensure all team members are using compatible Terraform versions
# 3. Review provider version constraints against the latest available versions
# 4. Document any provider-specific features or breaking changes that may impact the infrastructure
# 5. Set up version control hooks to validate Terraform version compliance