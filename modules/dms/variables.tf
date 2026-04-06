# =============================================================================
# DMS Module - Variables
# =============================================================================

variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for DMS resources"
  type        = string
}

variable "rds_hostname" {
  description = "AWS RDS hostname"
  type        = string
}

variable "rds_port" {
  description = "AWS RDS port"
  type        = number
  default     = 5432
}

variable "dms_replication_username" {
  description = "RDS Replication Username"
  type        = string
}

variable "dms_replication_password" {
  description = "RDS Replication Password"
  type        = string
  sensitive   = true
}

variable "cloudsql_public_ip" {
  description = "Cloud SQL Public IP address"
  type        = string
}

variable "cloudsql_admin_user" {
  description = "Cloud SQL admin user"
  type        = string
}

variable "cloudsql_admin_password" {
  description = "Cloud SQL admin password"
  type        = string
  sensitive   = true
}
