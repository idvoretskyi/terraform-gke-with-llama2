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
  ip_cidr_range = var.subnet_cidr
  description   = "Subnet for Llama2 GKE cluster"

  secondary_ip_range {
    range_name    = "${var.network_name}-pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "${var.network_name}-services"
    ip_cidr_range = var.services_cidr
  }
}

# Cloud NAT for outbound internet access from private nodes
resource "google_compute_router" "router" {
  project = var.project_id
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  project                            = var.project_id
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
