terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.14.0, < 7.26.1"
    }
  }

  required_version = ">= 1.5.0, < 2.0.0"

  # Remote backend for state storage with locking.
  # Create the bucket first:  gsutil mb -p <PROJECT> -l <REGION> gs://<BUCKET>
  backend "gcs" {
    bucket = "" # Set via -backend-config="bucket=<BUCKET_NAME>"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ---------------------------------------------------------------------------
# Locals -- values that rarely change and don't need to be user-facing
# ---------------------------------------------------------------------------

locals {
  network_name  = "llama2-network"
  cluster_name  = "llama2-jupyter-cluster"
  subnet_cidr   = "10.10.0.0/20"
  pods_cidr     = "10.20.0.0/14"
  services_cidr = "10.24.0.0/20"
  cpu_machine   = "e2-medium"
  disk_size_gb  = 100
}

# ---------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = local.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "${local.network_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = local.subnet_cidr

  secondary_ip_range {
    range_name    = "${local.network_name}-pods"
    ip_cidr_range = local.pods_cidr
  }

  secondary_ip_range {
    range_name    = "${local.network_name}-services"
    ip_cidr_range = local.services_cidr
  }
}

# ---------------------------------------------------------------------------
# GKE cluster
# ---------------------------------------------------------------------------

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 33.0"

  project_id               = var.project_id
  name                     = local.cluster_name
  region                   = var.region
  zones                    = [var.zone]
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  ip_range_pods            = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
  ip_range_services        = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
  initial_node_count       = 1
  remove_default_node_pool = true
  release_channel          = "REGULAR"
  deletion_protection      = false

  node_pools = [
    {
      name               = "cpu-node-pool"
      machine_type       = local.cpu_machine
      min_count          = 1
      max_count          = 3
      disk_size_gb       = local.disk_size_gb
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      spot               = true
      initial_node_count = 1
    },
    {
      name               = "gpu-node-pool"
      machine_type       = var.gpu_machine_type
      min_count          = 0
      max_count          = var.gpu_node_count
      disk_size_gb       = local.disk_size_gb
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      spot               = true
      initial_node_count = 0
      accelerator_count  = var.gpu_count
      accelerator_type   = var.gpu_type
    }
  ]

  node_pools_taints = {
    gpu-node-pool = [
      {
        key    = "nvidia.com/gpu"
        value  = "present"
        effect = "NO_SCHEDULE"
      }
    ]
  }

  node_pools_labels = {
    cpu-node-pool = { role = "jupyterhub-controller" }
    gpu-node-pool = { role = "gpu-inference" }
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "kubernetes_cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.name
}

output "kubernetes_cluster_host" {
  description = "GKE cluster host endpoint"
  value       = module.gke.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = module.gke.ca_certificate
  sensitive   = true
}

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${local.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "jupyter_access_command" {
  description = "Command to access JupyterHub via port-forward"
  value       = "kubectl port-forward service/proxy-public 8080:80"
}
