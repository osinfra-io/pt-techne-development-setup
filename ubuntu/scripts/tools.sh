#!/usr/bin/env bash

set -euo pipefail

trap 'echo "Error: Script failed at line ${LINENO}" >&2' ERR

# Verify Homebrew is installed
if [[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo "Error: Homebrew is not installed. Please run homebrew.sh first." >&2
    exit 1
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install \
  fzf \
  gh \
  go \
  helm \
  istioctl \
  jq \
  k9s \
  kubectl \
  kubectl-ai \
  kubectx \
  opa \
  opentofu \
  powerlevel10k \
  pre-commit \
  zsh-syntax-highlighting

# Automatically enable pre-commit on repositories

git config --global init.templateDir ${HOME}/.git-template
pre-commit init-templatedir ${HOME}/.git-template
