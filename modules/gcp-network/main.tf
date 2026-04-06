# =============================================================================
# GCP Network Module - Main
# =============================================================================
# Creates the GCP networking infrastructure:
#   - Custom VPC
#   - Subnet (10.20.0.0/24)
#   - Private Service Networking (for Cloud SQL private IP)
#   - Reserved IP range for Google-managed services
#   - Firewall rules for internal communication
# =============================================================================

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "VPC for Cloud SQL migration destination"
}

# -----------------------------------------------------------------------------
# Subnet
# -----------------------------------------------------------------------------
resource "google_compute_subnetwork" "main" {
  name                     = "${var.project_name}-subnet"
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.main.id
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Reserved IP Range for Private Service Networking
# Cloud SQL uses this range for its private IP allocation
# -----------------------------------------------------------------------------
resource "google_compute_global_address" "private_service_range" {
  name          = "${var.project_name}-private-svc-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = google_compute_network.main.id
  description   = "Reserved IP range for Cloud SQL private networking"
}

# -----------------------------------------------------------------------------
# Private Service Connection
# Establishes VPC peering with Google-managed services network
# -----------------------------------------------------------------------------
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_service_range.name]
}

# -----------------------------------------------------------------------------
# Firewall: Allow internal communication
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  project = var.project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
  description   = "Allow all internal traffic within the VPC subnet"
}

# -----------------------------------------------------------------------------
# Firewall: Allow PostgreSQL from private service range
# -----------------------------------------------------------------------------
resource "google_compute_firewall" "allow_postgres" {
  name    = "${var.project_name}-allow-postgres"
  project = var.project_id
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [google_compute_global_address.private_service_range.address]
  description   = "Allow PostgreSQL traffic from private service networking range"
}
