# terraform/modules/rds/outputs.tf
output "endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}
