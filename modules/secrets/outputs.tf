# =============================================================================
# Secrets Module - Outputs
# =============================================================================

output "cloudsql_password_secret_id" {
  description = "Secret ID for Cloud SQL password"
  value       = google_secret_manager_secret.cloudsql_password.secret_id
}

output "rds_password_secret_id" {
  description = "Secret ID for RDS password"
  value       = google_secret_manager_secret.rds_password.secret_id
}

output "dms_replication_password_secret_id" {
  description = "Secret ID for DMS replication password"
  value       = google_secret_manager_secret.dms_replication_password.secret_id
}
