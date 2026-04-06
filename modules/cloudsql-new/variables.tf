# =============================================================================
# Cloud SQL (New Instance) Module - Variables
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
  description = "GCP region"
  type        = string
}

variable "db_version" {
  description = "Cloud SQL PostgreSQL version (e.g., POSTGRES_14)"
  type        = string
}

variable "tier" {
  description = "Machine tier for Cloud SQL"
  type        = string
}

variable "db_name" {
  description = "Database name to create"
  type        = string
}

variable "db_user" {
  description = "Database admin username"
  type        = string
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "vpc_self_link" {
  description = "Self link of the VPC for private networking"
  type        = string
}

variable "private_service_connection_id" {
  description = "ID of the private service networking connection (used for depends_on)"
  type        = string
}

variable "enable_high_availability" {
  description = "Enable regional HA deployment"
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}
