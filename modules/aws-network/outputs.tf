# =============================================================================
# AWS Network Module - Outputs
# =============================================================================

output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the primary public subnet"
  value       = aws_subnet.public.id
}

output "public_subnet_b_id" {
  description = "ID of the secondary public subnet"
  value       = aws_subnet.public_b.id
}

output "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "postgres_security_group_id" {
  description = "ID of the PostgreSQL security group"
  value       = aws_security_group.postgres.id
}
