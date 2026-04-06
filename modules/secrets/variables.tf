# =============================================================================
# Secrets Module - Variables
# =============================================================================

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for secret replication"
  type        = string
}

variable "cloudsql_password" {
  description = "Cloud SQL admin user password"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "RDS master user password"
  type        = string
  sensitive   = true
}

variable "dms_replication_password" {
  description = "DMS replication user password"
  type        = string
  sensitive   = true
}
