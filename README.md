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

- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install), [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5, [kubectl](https://kubernetes.io/docs/tasks/tools/), [Helm](https://helm.sh/docs/intro/install/) >= 3.0
- A GCP project with **Kubernetes Engine**, **Compute Engine**, and **Artifact Registry** APIs enabled
- (Optional) A [HuggingFace access token](https://huggingface.co/settings/tokens) for gated model access

## Setup

### 1. Create the Terraform state bucket

```bash
export PROJECT_ID="your-gcp-project-id"
export REGION="us-central1"
export BUCKET="${PROJECT_ID}-tfstate"

gsutil mb -p "$PROJECT_ID" -l "$REGION" "gs://${BUCKET}"
gsutil versioning set on "gs://${BUCKET}"
```

### 2. Deploy infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # set your project_id
terraform init -backend-config="bucket=${BUCKET}"
terraform apply
```

### 3. Configure kubectl

```bash
# The exact command is also shown in `terraform output`
gcloud container clusters get-credentials llama2-jupyter-cluster \
  --region us-central1 --project "$PROJECT_ID"
```

### 4. Build and push the Docker image

```bash
export REGISTRY="${REGION}-docker.pkg.dev/${PROJECT_ID}/llama2"

gcloud artifacts repositories create llama2 \
  --repository-format=docker --location="$REGION" --project="$PROJECT_ID"

docker build -t "${REGISTRY}/llama2-jupyter:latest" docker/
docker push "${REGISTRY}/llama2-jupyter:latest"
```

Update `singleuser.image.name` in `k8s/jupyter-values.yaml` to your registry path.

### 5. Deploy JupyterHub

```bash
# (Optional) Provide a HuggingFace token for gated models
kubectl create secret generic hf-secret --from-literal=token="hf_YOUR_TOKEN"

helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
helm install jupyterhub jupyterhub/jupyterhub --values k8s/jupyter-values.yaml
```

### 6. Access JupyterHub

```bash
kubectl port-forward service/proxy-public 8080:80
```

Open <http://localhost:8080>.

## Using Llama2

Start a server with the **Llama2 GPU Environment** profile, then in a notebook:

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
cd terraform && terraform destroy
```

If destroy fails due to deletion protection:

```bash
gcloud container clusters update llama2-jupyter-cluster \
  --project "$PROJECT_ID" --region "$REGION" --no-deletion-protection
terraform destroy
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| GPU nodes not scheduling | Verify GPU quota in your GCP project; check `kubectl describe node` for taints |
| Model download fails | Ensure the `hf-secret` K8s secret has a valid HuggingFace token |
| Terraform state lock | Run `terraform force-unlock <LOCK_ID>` |

## Cost Optimization

Both node pools use **spot VMs** for significant savings. GPU nodes **scale to zero** when idle. Persistent storage keeps user data safe across spot preemptions.

> **Note:** GKE clusters on the REGULAR release channel with COS_CONTAINERD images install NVIDIA GPU drivers automatically. If you need manual installation for an older cluster version, apply the [official GKE GPU driver DaemonSet](https://raw.githubusercontent.com/GoogleCloudPlatform/container-engine-accelerators/master/nvidia-driver-installer/cos/daemonset-preloaded-latest.yaml).
