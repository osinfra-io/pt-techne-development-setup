#!/usr/bin/env bash

set -e

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

git config --global init.templateDir ~/.git-template
pre-commit init-templatedir ~/.git-template
