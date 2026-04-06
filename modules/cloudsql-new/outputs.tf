# =============================================================================
# Cloud SQL (New Instance) Module - Outputs
# =============================================================================

output "instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.name
}

output "instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.connection_name
}

output "instance_self_link" {
  description = "Self link of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.self_link
}

output "private_ip" {
  description = "Private IP of the Cloud SQL instance"
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "public_ip" {
  description = "Public IP of the Cloud SQL instance (if enabled)"
  value       = google_sql_database_instance.postgres.public_ip_address
}

output "database_name" {
  description = "Name of the database created"
  value       = google_sql_database.appdb.name
}
