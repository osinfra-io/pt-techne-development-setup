#!/usr/bin/env bash

set -euo pipefail

trap 'sleep 0.1; echo "Error: Script failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2; rm -f "$_errlog"' ERR

_errlog=$(mktemp)
exec 2> >(tee "$_errlog" >&2)

# Use the official Homebrew installation script (HEAD version)
# https://docs.brew.sh/Installation

if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo "Homebrew is already installed, skipping..."
else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
