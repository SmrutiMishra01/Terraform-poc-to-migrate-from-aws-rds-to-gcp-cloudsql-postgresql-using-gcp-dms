# =============================================================================
# Cloud SQL (Existing Instance) Module - Main
# =============================================================================
# References an EXISTING Cloud SQL PostgreSQL instance using a data source.
# Use this module when migrating to an already-provisioned Cloud SQL instance.
# =============================================================================

# -----------------------------------------------------------------------------
# Data Source: Existing Cloud SQL Instance
# -----------------------------------------------------------------------------
data "google_sql_database_instance" "existing" {
  name    = var.instance_name
  project = var.project_id
}
