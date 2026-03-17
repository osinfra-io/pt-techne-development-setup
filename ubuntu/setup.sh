#!/usr/bin/env bash

set -euo pipefail

trap 'echo "Error: Setup failed at line ${LINENO}" >&2' ERR

cd ~

# Download and run each setup script in order

scripts=(
    apt.sh
    homebrew.sh
    gcloud.sh
    tools.sh
    shell.sh
)

total=${#scripts[@]}
for i in "${!scripts[@]}"; do
    script="${scripts[$i]}"
    echo "[$((i+1))/${total}] Running ${script}..."
    curl -fsSL "https://raw.githubusercontent.com/osinfra-io/pt-techne-development-setup/main/ubuntu/scripts/$script" | bash
done

echo "Setup complete!"
