# Llama2 on GKE with GPU

Deploy [Llama2](https://huggingface.co/meta-llama/Llama-2-7b-hf) on a GPU-enabled GKE cluster with JupyterHub, using Terraform for infrastructure provisioning.

## Architecture

- **GKE cluster** with spot VMs for cost efficiency
- **Dedicated GPU node pool** with NVIDIA T4 GPUs (scales to zero when idle)
- **CPU node pool** for JupyterHub hub/proxy components
- **JupyterHub** for interactive model usage
- **Custom Docker image** with PyTorch, HuggingFace Transformers, and Llama2
- **GCS remote backend** for Terraform state with locking

## Prerequisites

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) >= 3.0
- A GCP project with the following APIs enabled:
  - Kubernetes Engine API
  - Compute Engine API
  - Artifact Registry API (or Container Registry API)
- (Optional) A [HuggingFace access token](https://huggingface.co/settings/tokens) for gated model access

## Setup

### 1. Create the Terraform state bucket

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"
export BUCKET_NAME="${PROJECT_ID}-tfstate"

gsutil mb -p "$PROJECT_ID" -l "$REGION" "gs://${BUCKET_NAME}"
gsutil versioning set on "gs://${BUCKET_NAME}"
```

### 2. Prepare configuration

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID and preferences
```

### 3. Initialize Terraform

```bash
terraform init -backend-config="bucket=${BUCKET_NAME}"
```

### 4. Apply the infrastructure

```bash
terraform apply
```

### 5. Configure kubectl

```bash
# The exact command is shown in Terraform outputs after apply
gcloud container clusters get-credentials llama2-jupyter-cluster \
  --region us-central1 --project "$PROJECT_ID"
```

### 6. (Optional) Install NVIDIA GPU drivers

Modern GKE clusters with COS_CONTAINERD images install GPU drivers automatically. If your cluster version requires manual installation:

```bash
kubectl apply -f k8s/nvidia-driver-installer.yaml
```

### 7. Build and push the Docker image

```bash
# Using Artifact Registry (recommended)
export REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/llama2"

# Create the repository (first time only)
gcloud artifacts repositories create llama2 \
  --repository-format=docker --location="$REGION" --project="$PROJECT_ID"

# Build and push
docker build -t "${REGISTRY}/llama2-jupyter:latest" docker/
docker push "${REGISTRY}/llama2-jupyter:latest"
```

Update `k8s/jupyter-values.yaml` to point `singleuser.image.name` to your registry path.

### 8. Set up the HuggingFace token (if using gated models)

```bash
kubectl create secret generic hf-secret --from-literal=token="hf_YOUR_TOKEN_HERE"
```

### 9. Install JupyterHub

```bash
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm install jupyterhub jupyterhub/jupyterhub --values k8s/jupyter-values.yaml
```

### 10. Access JupyterHub

```bash
kubectl port-forward service/proxy-public 8080:80
```

Open <http://localhost:8080> in your browser.

## Using Llama2

1. Log in and start a new server with the **Llama2 GPU Environment** profile.
2. Create a new notebook and use the model:

```python
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

model_id = "meta-llama/Llama-2-7b-hf"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForCausalLM.from_pretrained(
    model_id, torch_dtype=torch.float16, device_map="auto"
)

inputs = tokenizer("Hello, how are you?", return_tensors="pt").to("cuda")
outputs = model.generate(**inputs, max_new_tokens=50)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

## Clean Up

```bash
helm uninstall jupyterhub
terraform destroy
```

If `terraform destroy` fails due to deletion protection:

```bash
./manual_unlock.sh <project-id> <region> <cluster-name>
terraform destroy
```

## Cost Optimization

- **Spot VMs** -- both node pools use spot instances for significant cost savings.
- **Autoscaling** -- GPU nodes scale to zero when not in use.
- **Preemption risk** -- spot VMs may be reclaimed; persistent storage keeps user data safe across restarts.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| GPU nodes not scheduling | Verify GPU quota in your GCP project and check `kubectl describe node` for taints |
| Driver installer pod stuck | GKE may auto-install drivers; check if GPU device plugin pods are already running |
| Model download fails | Ensure `hf-secret` K8s secret exists with a valid HuggingFace token |
| Terraform state lock | Run `terraform force-unlock <LOCK_ID>` or use `manual_unlock.sh` |
