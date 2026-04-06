# =============================================================================
# Provider Configuration
# =============================================================================
# This file configures the required Terraform providers for the multi-cloud
# migration project: AWS (source) and Google Cloud (destination).
# Authentication is handled via CLI tools:
#   - AWS: `aws configure`
#   - GCP: `gcloud auth application-default login`
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
