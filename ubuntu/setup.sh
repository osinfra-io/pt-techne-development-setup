#!/usr/bin/env bash

set -e

cd ~

# Download and run each setup script in order

scripts=(
    apt.sh
    homebrew.sh
    gcloud.sh
    tools.sh
    shell.sh
)

for script in "${scripts[@]}"; do
    echo "Running $script..."
    curl -fsSL "https://raw.githubusercontent.com/osinfra-io/pt-techne-development-setup/main/ubuntu/scripts/$script" | bash
done

echo "Setup complete!"
