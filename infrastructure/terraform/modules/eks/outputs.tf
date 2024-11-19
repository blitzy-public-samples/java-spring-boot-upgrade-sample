# Outputs configuration for EKS module
# Addresses requirement: Infrastructure as Code - Provides necessary output values 
# from EKS module for container orchestration platform

output "cluster_endpoint" {
  description = "The endpoint URL for the EKS cluster API server"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = false
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.main.name
  sensitive   = false
}

output "cluster_security_group_id" {
  description = "The ID of the security group associated with the EKS cluster"
  value       = aws_security_group.cluster_sg.id
  sensitive   = false
}

output "cluster_iam_role_arn" {
  description = "The ARN of the IAM role used by the EKS cluster"
  value       = aws_iam_role.cluster_role.arn
  sensitive   = false
}

output "node_groups" {
  description = "Map of EKS node groups and their configurations"
  value = {
    for k, v in aws_eks_node_group.main : k => {
      arn           = v.arn
      status        = v.status
      capacity_type = v.capacity_type
      scaling_config = {
        desired_size = v.scaling_config[0].desired_size
        max_size     = v.scaling_config[0].max_size
        min_size     = v.scaling_config[0].min_size
      }
      instance_types = v.instance_types
      subnet_ids     = v.subnet_ids
    }
  }
  sensitive = false
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}