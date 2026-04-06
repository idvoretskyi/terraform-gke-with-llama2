# -----------------------------------------------------------------------------
# Cluster information outputs
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# Network outputs
# -----------------------------------------------------------------------------

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}

# -----------------------------------------------------------------------------
# Command helper outputs
# -----------------------------------------------------------------------------

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "jupyter_access_command" {
  description = "Command to access JupyterHub"
  value       = "kubectl port-forward service/proxy-public 8080:80"
}

output "jupyter_access_url" {
  description = "URL to access JupyterHub after port-forward"
  value       = "http://localhost:8080"
}
