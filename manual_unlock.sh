#!/bin/bash
set -euo pipefail

# This script manually disables deletion protection on a GKE cluster
# when Terraform cannot handle it (e.g., after an interrupted destroy).

if [ $# -lt 3 ]; then
	echo "Usage: $0 <project-id> <region> <cluster-name>"
	echo "Example: $0 my-gcp-project us-central1 llama2-jupyter-cluster"
	exit 1
fi

PROJECT_ID="$1"
REGION="$2"
CLUSTER_NAME="$3"

echo "Disabling deletion protection for cluster '${CLUSTER_NAME}' in '${REGION}'..."
echo ""
read -r -p "Are you sure you want to continue? [y/N] " response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
	echo "Aborted."
	exit 0
fi

gcloud container clusters update "${CLUSTER_NAME}" \
	--project "${PROJECT_ID}" \
	--region "${REGION}" \
	--no-deletion-protection

echo ""
echo "Deletion protection disabled. You can now run 'terraform destroy'."
