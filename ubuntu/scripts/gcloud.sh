#!/usr/bin/env bash

set -euo pipefail

trap 'sleep 0.1; echo "Error: Script failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2; rm -f "$_errlog"' ERR

_errlog=$(mktemp)
exec 2> >(tee "$_errlog" >&2)

# Check if both Google Cloud SDK packages are already installed
if dpkg-query -W -f='${Status}' google-cloud-sdk 2>/dev/null | grep -q "ok installed" && \
   dpkg-query -W -f='${Status}' google-cloud-sdk-gke-gcloud-auth-plugin 2>/dev/null | grep -q "ok installed"; then
    echo "Google Cloud SDK packages are already installed, skipping..."
    exit 0
fi

# Add Google Cloud apt source (idempotent - check if already present)
SOURCE_LINE="deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main"
SOURCE_FILE="/etc/apt/sources.list.d/google-cloud-sdk.list"

if [[ -f "${SOURCE_FILE}" ]] && grep -Fxq "${SOURCE_LINE}" "${SOURCE_FILE}"; then
    echo "Google Cloud apt source already configured, skipping..."
else
    echo "${SOURCE_LINE}" | sudo tee "${SOURCE_FILE}" > /dev/null
fi

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

sudo apt update && sudo apt -y install google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
