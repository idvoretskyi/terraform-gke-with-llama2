terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.14.0, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 6.14.0, < 7.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
  }

  required_version = ">= 1.5.0, < 2.0.0"

  # Remote backend for state storage with locking
  # Create the GCS bucket before running terraform init:
  #   gsutil mb -p <PROJECT_ID> -l <REGION> gs://<BUCKET_NAME>
  #   gsutil versioning set on gs://<BUCKET_NAME>
  backend "gcs" {
    bucket = "" # Set via -backend-config="bucket=<BUCKET_NAME>" or in backend.hcl
    prefix = "terraform/state"
  }
}

# Configure Google providers
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Get credentials for Kubernetes provider
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}
