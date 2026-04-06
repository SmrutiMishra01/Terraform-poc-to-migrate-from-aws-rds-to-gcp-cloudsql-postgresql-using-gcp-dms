# =============================================================================
# DMS Module - Main
# =============================================================================

# GCS Bucket for Database Migration Service Dumps
resource "google_storage_bucket" "dms_bucket" {
  name          = "${var.project_name}-dms-bucket-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true

  labels = {
    project = var.project_name
  }

  # Aggressive Lifecycle: Delete objects after 1 day to ensure migration dumps don't sit in storage
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
