# =============================================================================
# Cloud SQL (Existing Instance) Module - Outputs
# =============================================================================

output "instance_name" {
  description = "Name of the existing Cloud SQL instance"
  value       = data.google_sql_database_instance.existing.name
}

output "instance_connection_name" {
  description = "Connection name of the existing Cloud SQL instance"
  value       = data.google_sql_database_instance.existing.connection_name
}

output "instance_self_link" {
  description = "Self link of the existing Cloud SQL instance"
  value       = data.google_sql_database_instance.existing.self_link
}
