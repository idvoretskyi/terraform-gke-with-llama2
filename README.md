# Llama2 on GKE with GPU

This Terraform project deploys Llama2 from HuggingFace on a GPU-enabled Jupyter cluster using Google Kubernetes Engine with preemptible nodes for cost efficiency.

## Architecture

- GKE cluster with preemptible nodes (cost-effective)
- Dedicated GPU node pool with NVIDIA T4 GPUs for Llama2 inference
- JupyterHub for interactive model usage
- Custom Docker image with PyTorch, HuggingFace, and Llama2 support

## Prerequisites

- Google Cloud SDK installed and configured
- Terraform 1.0.0 or later installed
- Access to a Google Cloud project with necessary APIs enabled:
  - Kubernetes Engine API
  - Compute Engine API
  - Container Registry API

## Setup

1. **Prepare configuration**

   Copy the example variables file and edit as needed:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your project ID and any other customizations
   ```

2. **Initialize Terraform**

   ```bash
   terraform init
   ```

3. **Apply the configuration**

   ```bash
   terraform apply
   ```

4. **Install NVIDIA drivers**

   After the cluster is created, apply the NVIDIA driver installer:

   ```bash
   kubectl apply -f k8s/nvidia-driver-installer.yaml
   ```

5. **Install JupyterHub**

   ```bash
   helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
   helm repo update
   helm install jupyterhub jupyterhub/jupyterhub --values k8s/jupyter-values.yaml
   ```

6. **Access JupyterHub**

   ```bash
   kubectl port-forward service/proxy-public 8080:80
   ```

   Open http://localhost:8080 in your browser

## Using Llama2

1. Start a new Jupyter server with the "Llama2 GPU Environment" profile
2. Open the example notebook or create a new one
3. Follow the example code to utilize the Llama2 model with GPU acceleration

## Clean Up

To delete all resources:

```bash
terraform destroy
```

## Cost Optimization

This deployment uses preemptible VMs and auto-scaling to minimize costs. The GPU nodes will scale to zero when not in use, and preemptible instances provide significant cost savings.
# terraform-gke-with-llama2
