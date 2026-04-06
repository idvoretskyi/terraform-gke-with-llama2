variable "project_id" {
  description = "GCP Project ID"
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id must not be empty."
  }
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "gpu_machine_type" {
  description = "Machine type for GPU nodes (must support GPU attachment, e.g. N1 or A2 family)"
  type        = string
  default     = "n1-standard-8"
}

variable "gpu_type" {
  description = "GPU accelerator type (e.g. nvidia-tesla-t4, nvidia-tesla-v100, nvidia-tesla-a100)"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count" {
  description = "Number of GPUs per node"
  type        = number
  default     = 1
}

variable "gpu_node_count" {
  description = "Maximum number of GPU nodes in the node pool"
  type        = number
  default     = 1
}
