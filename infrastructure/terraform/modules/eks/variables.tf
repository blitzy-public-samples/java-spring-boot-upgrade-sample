# Human Tasks:
# 1. Review and adjust node group configurations based on workload requirements
# 2. Verify subnet configurations meet EKS requirements (proper tagging and routing)
# 3. Ensure proper IAM roles and permissions are in place for EKS cluster
# 4. Review and adjust cluster version based on application compatibility
# 5. Configure environment-specific values in tfvars files

# Requirement Addressed: Kubernetes Infrastructure
# Location: Technical Specification/Infrastructure/Kubernetes
# Description: Defines variables needed for EKS cluster provisioning with proper security,
# scalability, and high availability configurations

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"

  validation {
    condition     = length(var.cluster_name) <= 100
    error_message = "Cluster name must be less than 100 characters"
  }
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.27"

  validation {
    condition     = can(regex("^1\\.(2[4-7])$", var.cluster_version))
    error_message = "Cluster version must be between 1.24 and 1.27"
  }
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where EKS cluster will be deployed"

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must start with 'vpc-'"
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS node groups. Must be in at least two different availability zones"

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least two subnet IDs are required for high availability"
  }
}

variable "node_groups" {
  type = map(object({
    desired_size    = number
    min_size       = number
    max_size       = number
    instance_types = list(string)
    capacity_type  = optional(string)
    disk_size     = optional(number)
  }))
  description = "Configuration for EKS node groups including instance types and scaling settings"
  default = {
    default = {
      desired_size   = 2
      min_size      = 1
      max_size      = 4
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      disk_size     = 20
    }
  }

  validation {
    condition     = alltrue([for k, v in var.node_groups : v.min_size <= v.desired_size && v.desired_size <= v.max_size])
    error_message = "Node group sizes must satisfy: min_size <= desired_size <= max_size"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all EKS resources for better resource management and cost tracking"
  default     = {}
}

variable "environment" {
  type        = string
  description = "Deployment environment (dev/prod) inherited from main configuration"
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'"
  }
}