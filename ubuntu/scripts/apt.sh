#!/usr/bin/env bash

set -euo pipefail

_errlog=$(mktemp)
trap 'rm -f "${_errlog:-}"' EXIT
trap 'sleep 0.1; echo "Error: Script failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2' ERR
exec 2> >(tee "$_errlog" >&2)

# Update package lists
sudo apt update

# Install vim if not already installed
if ! command -v vim &> /dev/null; then
    sudo apt -y install vim
else
    echo "vim is already installed, skipping..."
fi
