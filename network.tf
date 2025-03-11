# VPC network for the GKE cluster
resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  description             = "VPC network for Llama2 GKE cluster"
}

# Subnet for the GKE cluster
resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "${var.network_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
  description   = "Subnet for Llama2 GKE cluster"
}
