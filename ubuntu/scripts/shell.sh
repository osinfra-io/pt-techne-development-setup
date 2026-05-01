#!/usr/bin/env bash

set -euo pipefail

_errlog=$(mktemp)
trap 'rm -f "${_errlog:-}"' EXIT
trap 'sleep 0.1; echo "Error: Script failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2' ERR
exec 2> >(tee "$_errlog" >&2)

cd ${HOME}

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Copy p10k config if running locally (Docker handles this via COPY instruction)

P10K_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.p10k.zsh"
if [[ -f "${P10K_SOURCE}" ]] && [[ ! -f "${HOME}/.p10k.zsh" ]]; then
    cp "${P10K_SOURCE}" "${HOME}/.p10k.zsh"
fi

# Zsh

ZSH_PATH="$(command -v zsh)"
if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi
sudo chsh "$(whoami)" -s "$ZSH_PATH"

# Vim

cat << EOF > ${HOME}/.vimrc
set visualbell

filetype plugin indent on
syntax on
EOF

# Oh My Zsh

if [ ! -f ${HOME}/.oh-my-zsh/oh-my-zsh.sh ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# zsh-autosuggestions

if [ ! -d "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# Shell setup

if [ -f ${HOME}/.zshrc ]; then
  cp ${HOME}/.zshrc ${HOME}/.zshrc-"$(date +"%Y%m%d_%H%M%S")".bak
fi

# Comment out default plugins

sed -i '/^plugins=(git)$/s/^/#/' ${HOME}/.zshrc

# Add custom shell configuration (idempotent - check for marker)
if ! grep -q "# SHELL_SH_MARKER" "${HOME}/.zshrc"; then
    cat << 'EOF' >> ${HOME}/.zshrc

# SHELL_SH_MARKER - Configuration added by shell.sh setup script
alias gpg-passphrase='echo "test" | gpg --clearsign > /dev/null 2>&1'

export GOOGLE_AUTH_SUPPRESS_CREDENTIALS_WARNINGS=true
export GPG_TTY=${TTY}
export EDITOR=vim

zstyle ':completion::complete:*' use-cache 1

[[ ! -f ${HOME}/.p10k.zsh ]] || source ${HOME}/.p10k.zsh
[[ ! -f ${HOME}/.exports ]] || source ${HOME}/.exports

source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/linuxbrew/.linuxbrew/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme

unsetopt correct_all
setopt correct

# Only initialize gh copilot alias if the extension is installed
if gh extension list 2>/dev/null | grep -q "github/gh-copilot"; then
    eval "$(gh copilot alias -- zsh)"
fi

eval "$(fzf --zsh)"
EOF
fi

# Add plugins to the beginning (idempotent - check if already present)
if ! grep -q "^plugins=(git terraform gcloud docker kubectl helm zsh-autosuggestions)" "${HOME}/.zshrc"; then
    temp_file=$(mktemp)
    printf '%s\n' "plugins=(git terraform gcloud docker kubectl helm zsh-autosuggestions)" > "${temp_file}"
    cat "${HOME}/.zshrc" >> "${temp_file}"
    mv "${temp_file}" "${HOME}/.zshrc"
fi

# Add brew shellenv to the beginning (idempotent)
if ! grep -q "eval.*brew shellenv" "${HOME}/.zshrc"; then
    temp_file=$(mktemp)
    printf '%s\n' 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' > "${temp_file}"
    cat "${HOME}/.zshrc" >> "${temp_file}"
    mv "${temp_file}" "${HOME}/.zshrc"
fi

# Add HOME/bin to PATH (idempotent)
if ! grep -q "export PATH=\$HOME/bin:\$PATH" "${HOME}/.zshrc"; then
    temp_file=$(mktemp)
    printf '%s\n' 'export PATH=$HOME/bin:$PATH' > "${temp_file}"
    cat "${HOME}/.zshrc" >> "${temp_file}"
    mv "${temp_file}" "${HOME}/.zshrc"
fi

# Create update script

mkdir -p ${HOME}/bin
cat << 'EOF' > ${HOME}/bin/update.zsh
#!/usr/bin/env zsh

source ${HOME}/.zshrc

# Oh-my-zsh
${ZSH}/tools/upgrade.sh

# Ubuntu
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

# Brew
brew update
brew upgrade
brew autoremove
brew cleanup

# GitHub
gh extension upgrade --all

# zsh-autosuggestions
cd "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git pull
cd - > /dev/null

echo "All updates complete!"
EOF

chmod 755 ${HOME}/bin/update.zsh
