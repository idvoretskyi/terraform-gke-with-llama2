# Project variables
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

# Location variables
variable "region" {
  description = "GCP region for regional resources"
  default     = "us-central1"
  type        = string
}

variable "zone" {
  description = "GCP zone for zonal resources"
  default     = "us-central1-a"
  type        = string
}

# Network variables
variable "network_name" {
  description = "VPC network name"
  default     = "llama2-network"
  type        = string
}

# Cluster variables
variable "cluster_name" {
  description = "Name of the GKE cluster"
  default     = "llama2-jupyter-cluster"
  type        = string
}

# GPU node pool variables
variable "gpu_node_count" {
  description = "Maximum number of GPU nodes in the node pool"
  default     = 1
  type        = number
}

variable "machine_type" {
  description = "Machine type for GPU nodes"
  default     = "n1-standard-8"
  type        = string
}

variable "gpu_type" {
  description = "Type of GPU to attach to nodes"
  default     = "nvidia-tesla-t4"
  type        = string
}

variable "gpu_count" {
  description = "Number of GPUs per node"
  default     = 1
  type        = number
}
