# -----------------------------------------------------------------------------
# Project variables
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "GCP Project ID"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

# -----------------------------------------------------------------------------
# Location variables
# -----------------------------------------------------------------------------

variable "region" {
  description = "GCP region for regional resources"
  type        = string
  default     = "us-central1"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.region))
    error_message = "region must be a valid GCP region (e.g., us-central1, europe-west1)."
  }
}

variable "zone" {
  description = "GCP zone for zonal resources"
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]-[a-z]$", var.zone))
    error_message = "zone must be a valid GCP zone (e.g., us-central1-a)."
  }
}

# -----------------------------------------------------------------------------
# Network variables
# -----------------------------------------------------------------------------

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "llama2-network"
}

variable "subnet_cidr" {
  description = "Primary CIDR range for the subnet"
  type        = string
  default     = "10.10.0.0/20"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid CIDR block."
  }
}

variable "pods_cidr" {
  description = "Secondary CIDR range for GKE pods"
  type        = string
  default     = "10.20.0.0/14"

  validation {
    condition     = can(cidrhost(var.pods_cidr, 0))
    error_message = "pods_cidr must be a valid CIDR block."
  }
}

variable "services_cidr" {
  description = "Secondary CIDR range for GKE services"
  type        = string
  default     = "10.24.0.0/20"

  validation {
    condition     = can(cidrhost(var.services_cidr, 0))
    error_message = "services_cidr must be a valid CIDR block."
  }
}

# -----------------------------------------------------------------------------
# Cluster variables
# -----------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "llama2-jupyter-cluster"
}

# -----------------------------------------------------------------------------
# CPU node pool variables
# -----------------------------------------------------------------------------

variable "cpu_machine_type" {
  description = "Machine type for CPU nodes (JupyterHub controller)"
  type        = string
  default     = "e2-medium"
}

# -----------------------------------------------------------------------------
# GPU node pool variables
# -----------------------------------------------------------------------------

variable "gpu_node_count" {
  description = "Maximum number of GPU nodes in the node pool"
  type        = number
  default     = 1

  validation {
    condition     = var.gpu_node_count >= 0
    error_message = "gpu_node_count must be >= 0."
  }
}

variable "gpu_machine_type" {
  description = "Machine type for GPU nodes"
  type        = string
  default     = "n1-standard-8"
}

variable "gpu_type" {
  description = "Type of GPU to attach to nodes"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count" {
  description = "Number of GPUs per node"
  type        = number
  default     = 1

  validation {
    condition     = var.gpu_count >= 1
    error_message = "gpu_count must be >= 1."
  }
}

# -----------------------------------------------------------------------------
# Node pool shared variables
# -----------------------------------------------------------------------------

variable "disk_size_gb" {
  description = "Disk size in GB for node pool instances"
  type        = number
  default     = 100

  validation {
    condition     = var.disk_size_gb >= 50
    error_message = "disk_size_gb must be >= 50."
  }
}
