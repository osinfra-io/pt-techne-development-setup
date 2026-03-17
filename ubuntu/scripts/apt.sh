#!/usr/bin/env bash

set -euo pipefail

trap 'echo "Error: Script failed at line ${LINENO}" >&2' ERR

# Update package lists
sudo apt update

# Install vim if not already installed
if ! command -v vim &> /dev/null; then
    sudo apt -y install vim
else
    echo "vim is already installed, skipping..."
fi
