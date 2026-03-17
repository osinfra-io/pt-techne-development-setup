#!/usr/bin/env bash

set -euo pipefail

trap 'echo "Error: Script failed at line ${LINENO}" >&2' ERR

# Use the official Homebrew installation script (HEAD version)
# https://docs.brew.sh/Installation

if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo "Homebrew is already installed, skipping..."
else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
