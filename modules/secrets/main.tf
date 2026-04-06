# =============================================================================
# Secrets Module - Main
# =============================================================================
# Manages sensitive credentials using Google Cloud Secret Manager:
#   - Cloud SQL admin password
#   - RDS master password
#   - DMS replication user password
#
# Passwords are stored as secret versions and can be referenced by other
# services without exposing them in Terraform state.
# =============================================================================

# -----------------------------------------------------------------------------
# Cloud SQL Password Secret
# -----------------------------------------------------------------------------
resource "google_secret_manager_secret" "cloudsql_password" {
  secret_id = "${var.project_name}-cloudsql-password"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  labels = {
    project = var.project_name
    purpose = "cloudsql-admin-password"
  }
}

resource "google_secret_manager_secret_version" "cloudsql_password" {
  secret      = google_secret_manager_secret.cloudsql_password.id
  secret_data = var.cloudsql_password
}

# -----------------------------------------------------------------------------
# RDS Password Secret
# -----------------------------------------------------------------------------
resource "google_secret_manager_secret" "rds_password" {
  secret_id = "${var.project_name}-rds-password"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  labels = {
    project = var.project_name
    purpose = "rds-master-password"
  }
}

resource "google_secret_manager_secret_version" "rds_password" {
  secret      = google_secret_manager_secret.rds_password.id
  secret_data = var.rds_password
}

# -----------------------------------------------------------------------------
# DMS Replication User Password Secret
# -----------------------------------------------------------------------------
resource "google_secret_manager_secret" "dms_replication_password" {
  secret_id = "${var.project_name}-dms-replication-password"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  labels = {
    project = var.project_name
    purpose = "dms-replication-password"
  }
}

resource "google_secret_manager_secret_version" "dms_replication_password" {
  secret      = google_secret_manager_secret.dms_replication_password.id
  secret_data = var.dms_replication_password
}
