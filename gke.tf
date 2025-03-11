resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  project       = var.project_id
  name          = "${var.network_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}

# GKE cluster with GPU support
module "gke" {
  source                   = "terraform-google-modules/kubernetes-engine/google"
  project_id               = var.project_id
  name                     = var.cluster_name
  region                   = var.region
  zones                    = [var.zone]
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  ip_range_pods            = ""
  ip_range_services        = ""
  initial_node_count       = 1
  remove_default_node_pool = true
  release_channel          = "REGULAR"
  deletion_protection      = false
  
  # Node pools configuration
  node_pools = [
    {
      # CPU node pool for JupyterHub controller
      name               = "cpu-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 3
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true
      initial_node_count = 1
    },
    {
      # GPU node pool for Llama2 model inference
      name               = "gpu-node-pool"
      machine_type       = var.machine_type
      min_count          = 0
      max_count          = var.gpu_node_count
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = true
      initial_node_count = 0
      accelerator_count  = var.gpu_count
      accelerator_type   = var.gpu_type
    }
  ]

  # Taints to ensure GPU nodes are only used for GPU workloads
  node_pools_taints = {
    gpu-node-pool = [
      {
        key    = "nvidia.com/gpu"
        value  = "present"
        effect = "NO_SCHEDULE"
      }
    ]
  }
}
