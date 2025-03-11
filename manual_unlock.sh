#!/bin/bash

# This script manually disables deletion protection on a GKE cluster if Terraform can't handle it

if [ $# -lt 3 ]; then
  echo "Usage: $0 <project-id> <region> <cluster-name>"
  echo "Example: $0 idv-dev-0 us-central1 llama2-jupyter-cluster"
  exit 1
fi

PROJECT_ID=$1
REGION=$2
CLUSTER_NAME=$3

echo "Disabling deletion protection for cluster ${CLUSTER_NAME} in ${REGION}..."

# First try with standard gcloud command
gcloud container clusters update ${CLUSTER_NAME} \
  --project ${PROJECT_ID} \
  --region ${REGION} \
  --no-enable-master-authorized-networks \
  --no-deletion-protection

echo "Deletion protection disabled. You can now run 'terraform destroy' again."
echo "If you still encounter issues, try running:"
echo "gcloud beta container clusters update ${CLUSTER_NAME} --region ${REGION} --no-deletion-protection --project ${PROJECT_ID}"
