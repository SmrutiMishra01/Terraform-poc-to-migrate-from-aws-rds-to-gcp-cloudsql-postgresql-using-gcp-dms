# =============================================================================
# GCP Network Module - Outputs
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.main.id
}

output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.main.name
}

output "vpc_self_link" {
  description = "Self link of the VPC"
  value       = google_compute_network.main.self_link
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = google_compute_subnetwork.main.id
}

output "subnet_self_link" {
  description = "Self link of the subnet"
  value       = google_compute_subnetwork.main.self_link
}

output "private_service_connection_id" {
  description = "ID of the private service networking connection"
  value       = google_service_networking_connection.private_vpc_connection.id
}

output "private_ip_range_name" {
  description = "Name of the reserved private IP range"
  value       = google_compute_global_address.private_service_range.name
}
