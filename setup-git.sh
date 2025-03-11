#!/bin/bash

set -e

echo "Setting up Git repository for terraform-gke-with-llama2..."

# Check if we're already in a git repository
if [ -d .git ]; then
  echo "Git repository already initialized."
  
  # Check current remotes
  echo "Current Git remotes:"
  git remote -v
  
  # Remove existing origin if needed
  echo "Removing existing origin remote..."
  git remote remove origin
fi

# Add the remote
echo "Adding GitHub remote..."
git remote add origin https://github.com/idvoretskyi/terraform-gke-with-llama2.git

# Initialize Git if needed
if [ ! -d .git ]; then
  echo "Initializing Git repository..."
  git init
fi

# Add all files
echo "Adding files to Git..."
git add .

# Create initial commit if needed
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "Creating initial commit..."
  git commit -m "Initial commit: Setup Terraform for Llama2 on GKE with GPU"
else
  echo "Creating commit with latest changes..."
  git commit -m "Update Terraform configuration for Llama2 on GKE with GPU"
fi

# Get current branch name or create main branch
if [ -z "$(git branch --show-current)" ]; then
  echo "Creating main branch..."
  git checkout -b main
else
  CURRENT_BRANCH=$(git branch --show-current)
  if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "Current branch is $CURRENT_BRANCH, creating and switching to main branch..."
    git checkout -b main
  fi
fi

# Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

echo "Git setup complete! Your code is now on GitHub at: https://github.com/idvoretskyi/terraform-gke-with-llama2"
