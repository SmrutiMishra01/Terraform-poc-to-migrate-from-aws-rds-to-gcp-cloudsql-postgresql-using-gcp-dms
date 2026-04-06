# =============================================================================
# Cloud SQL (Existing Instance) Module - Variables
# =============================================================================

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "instance_name" {
  description = "Name of the existing Cloud SQL instance"
  type        = string
}
