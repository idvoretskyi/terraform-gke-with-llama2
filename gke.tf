# GKE cluster with GPU support
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 33.0"

  project_id               = var.project_id
  name                     = var.cluster_name
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

  # Node pools configuration
  node_pools = [
    {
      # CPU node pool for JupyterHub controller
      name               = "cpu-node-pool"
      machine_type       = var.cpu_machine_type
      min_count          = 1
      max_count          = 3
      disk_size_gb       = var.disk_size_gb
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      spot               = true
      initial_node_count = 1
    },
    {
      # GPU node pool for Llama2 model inference
      name               = "gpu-node-pool"
      machine_type       = var.gpu_machine_type
      min_count          = 0
      max_count          = var.gpu_node_count
      disk_size_gb       = var.disk_size_gb
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

  # Labels for cost tracking and management
  node_pools_labels = {
    cpu-node-pool = {
      role = "jupyterhub-controller"
    }
    gpu-node-pool = {
      role = "gpu-inference"
    }
  }
}
