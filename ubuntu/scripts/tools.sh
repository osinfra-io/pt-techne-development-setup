#!/usr/bin/env bash

set -euo pipefail

_errlog=$(mktemp)
trap 'rm -f "${_errlog:-}"' EXIT
trap 'sleep 0.1; echo "Error: Script failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2' ERR
exec 2> >(tee "$_errlog" >&2)

# Verify Homebrew is installed
if [[ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    echo "Error: Homebrew is not installed. Please run homebrew.sh first." >&2
    exit 1
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

brew install \
  copilot-cli \
  fzf \
  gh \
  go \
  helm \
  istioctl \
  k9s \
  kubectl \
  kubectl-ai \
  kubectx \
  node \
  opa \
  opentofu \
  regal \
  vegeta \
  yarn \
  powerlevel10k \
  pre-commit \
  zsh \
  zsh-syntax-highlighting

# Automatically enable pre-commit on repositories

git config --global init.templateDir ${HOME}/.git-template
pre-commit init-templatedir ${HOME}/.git-template
