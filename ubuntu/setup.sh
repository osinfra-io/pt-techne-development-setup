#!/usr/bin/env bash

set -euo pipefail

_errlog=$(mktemp)
trap 'rm -f "${_errlog:-}"' EXIT
trap 'sleep 0.1; echo "Error: Setup failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2' ERR
exec 2> >(tee "$_errlog" >&2)

# Set to true to run scripts from the local filesystem instead of GitHub
LOCAL=${LOCAL:-false}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts"

cd ~

scripts=(
    apt.sh
    homebrew.sh
    gcloud.sh
    tools.sh
    shell.sh
)

# Run each setup script in order

total=${#scripts[@]}
for i in "${!scripts[@]}"; do
    script="${scripts[$i]}"
    echo "[$((i+1))/${total}] Running ${script}..."
    if [[ "${LOCAL}" == "true" ]]; then
        bash "${SCRIPT_DIR}/${script}"
    else
        curl -fsSL "https://raw.githubusercontent.com/osinfra-io/pt-techne-development-setup/main/ubuntu/scripts/$script" | bash
    fi
done

echo "Setup complete!"
