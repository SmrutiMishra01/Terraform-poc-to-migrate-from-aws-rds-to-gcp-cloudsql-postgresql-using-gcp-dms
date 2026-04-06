# =============================================================================
# Cloud SQL (New Instance) Module - Main
# =============================================================================
# Creates a NEW Cloud SQL PostgreSQL instance for migration destination:
#   - Private networking via VPC peering
#   - Database and user creation
#   - Configured for DMS migration compatibility
#
# The instance uses private IP only for security best practices.
# =============================================================================

# -----------------------------------------------------------------------------
# Cloud SQL PostgreSQL Instance
# -----------------------------------------------------------------------------
resource "google_sql_database_instance" "postgres" {
  name             = "${var.project_name}-cloudsql-pg"
  project          = var.project_id
  region           = var.region
  database_version = var.db_version

  # Ensure private service networking is established before creating
  depends_on = [var.private_service_connection_id]

  # Prevent accidental deletion in production
  deletion_protection = var.deletion_protection

  settings {
    tier              = var.tier
    availability_type = var.enable_high_availability ? "REGIONAL" : "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    user_labels = {
      project = var.project_name
    }

    # Private networking configuration
    ip_configuration {
      ipv4_enabled                                  = true # Enable public IP for DMS connectivity
      private_network                               = var.vpc_self_link
      enable_private_path_for_google_cloud_services = true
    }

    # Backup configuration
    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    # Database flags for PostgreSQL
    database_flags {
      name  = "max_connections"
      value = "100"
    }

    # Maintenance window
    maintenance_window {
      day          = 1 # Monday
      hour         = 4
      update_track = "stable"
    }
  }
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------
resource "google_sql_database" "appdb" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
}

# -----------------------------------------------------------------------------
# Database User
# -----------------------------------------------------------------------------
resource "google_sql_user" "admin" {
  name     = var.db_user
  project  = var.project_id
  instance = google_sql_database_instance.postgres.name
  password = var.db_password
}
