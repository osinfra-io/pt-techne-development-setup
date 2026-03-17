#!/usr/bin/env bash

set -euo pipefail

trap 'echo "Error: Script failed at line ${LINENO}" >&2' ERR

# Check if gcloud is already installed
if command -v gcloud &> /dev/null; then
    echo "Google Cloud SDK is already installed, skipping..."
    exit 0
fi

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

sudo apt update && sudo apt -y install google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
