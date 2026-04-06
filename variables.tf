# =============================================================================
# Root Variables
# =============================================================================
# These variables are shared across the project and passed down to modules.
# Sensitive values (passwords) should be set via terraform.tfvars or
# environment variables (TF_VAR_*), never hardcoded.
# =============================================================================

# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "dms-pg-migration"
}

# -----------------------------------------------------------------------------
# AWS Configuration
# -----------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region for source infrastructure"
  type        = string
  default     = "ap-south-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for the AWS VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "aws_public_subnet_cidr" {
  description = "CIDR block for the AWS public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version for RDS"
  type        = string
  default     = "14"
}

variable "rds_instance_class" {
  description = "RDS instance class (use db.t3.micro for demo)"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage in GB for RDS"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Name of the database to create on RDS"
  type        = string
  default     = "appdb"
}

variable "rds_username" {
  description = "Master username for RDS"
  type        = string
  default     = "postgres"
}

variable "rds_password" {
  description = "Master password for RDS PostgreSQL (set via tfvars or TF_VAR_rds_password)"
  type        = string
  sensitive   = true
}

variable "dms_replication_username" {
  description = "Username for the DMS replication user on RDS"
  type        = string
  default     = "dmsuser"
}

variable "dms_replication_password" {
  description = "Password for the DMS replication user on RDS"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# GCP Configuration
# -----------------------------------------------------------------------------
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for destination infrastructure"
  type        = string
  default     = "asia-south1"
}

variable "gcp_subnet_cidr" {
  description = "CIDR block for the GCP subnet"
  type        = string
  default     = "10.20.0.0/24"
}

variable "cloudsql_tier" {
  description = "Machine tier for Cloud SQL (use db-f1-micro for demo)"
  type        = string
  default     = "db-f1-micro"
}

variable "cloudsql_db_version" {
  description = "PostgreSQL version for Cloud SQL"
  type        = string
  default     = "POSTGRES_14"
}

variable "cloudsql_db_name" {
  description = "Database name on Cloud SQL"
  type        = string
  default     = "appdb"
}

variable "cloudsql_user" {
  description = "Database admin user for Cloud SQL"
  type        = string
  default     = "dbadmin"
}

variable "cloudsql_password" {
  description = "Password for the Cloud SQL admin user (set via tfvars or TF_VAR_cloudsql_password)"
  type        = string
  sensitive   = true
}
