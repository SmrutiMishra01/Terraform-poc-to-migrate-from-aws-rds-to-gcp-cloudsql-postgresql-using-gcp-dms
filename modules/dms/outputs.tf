# =============================================================================
# DMS Module - Outputs
# =============================================================================

# output "migration_job_id" {
#   description = "ID of the DMS migration job"
#   value       = google_database_migration_service_migration_job.pg_migration.migration_job_id
# }

# output "migration_job_name" {
#   description = "Full resource name of the migration job"
#   value       = google_database_migration_service_migration_job.pg_migration.name
# }

# output "source_profile_id" {
#   description = "ID of the source connection profile"
#   value       = google_database_migration_service_connection_profile.source.connection_profile_id
# }

# output "destination_profile_id" {
#   description = "ID of the destination connection profile"
#   value       = google_database_migration_service_connection_profile.destination.connection_profile_id
# }

output "gcs_bucket_name" {
  description = "Name of the GCS bucket used for DMS dump files"
  value       = google_storage_bucket.dms_bucket.name
}

output "gcs_bucket_url" {
  description = "URL of the GCS bucket"
  value       = google_storage_bucket.dms_bucket.url
}
