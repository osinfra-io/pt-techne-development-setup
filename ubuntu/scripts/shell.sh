#!/usr/bin/env bash

set -euo pipefail

_errlog=$(mktemp)
trap 'rm -f "${_errlog:-}"' EXIT
trap 'sleep 0.1; echo "Error: Script failed at line ${LINENO}" >&2; tail -5 "$_errlog" >&2' ERR
exec 2> >(tee "$_errlog" >&2)

cd ${HOME}

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Copy p10k config if running locally (Docker handles this via COPY instruction)

P10K_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/files/.p10k.zsh"
if [[ -f "${P10K_SOURCE}" ]] && [[ ! -f "${HOME}/.p10k.zsh" ]]; then
    cp "${P10K_SOURCE}" "${HOME}/.p10k.zsh"
fi

# Copy vimrc config if running locally (Docker handles this via COPY instruction)

VIMRC_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/files/.vimrc"
if [[ -f "${VIMRC_SOURCE}" ]] && [[ ! -f "${HOME}/.vimrc" ]]; then
    cp "${VIMRC_SOURCE}" "${HOME}/.vimrc"
fi

# Copy k9s config if running locally (Docker handles this via COPY instruction)

K9S_SOURCE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/files/k9s"
if [[ -d "${K9S_SOURCE}" ]] && [[ ! -d "${HOME}/.config/k9s" ]]; then
    mkdir -p "${HOME}/.config"
    cp -r "${K9S_SOURCE}" "${HOME}/.config/k9s"
fi

# Zsh

ZSH_PATH="$(command -v zsh)"
if ! grep -qF "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi
sudo chsh "$(whoami)" -s "$ZSH_PATH"

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
export TF_PLUGIN_CACHE_DIR=$HOME/.opentofu.d/plugin-cache

zstyle ':completion::complete:*' use-cache 1

[[ ! -f ${HOME}/.p10k.zsh ]] || source ${HOME}/.p10k.zsh
[[ ! -f ${HOME}/.exports ]] || source ${HOME}/.exports

source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/linuxbrew/.linuxbrew/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme

unsetopt correct_all
setopt correct

eval "$(dircolors -p | \
    sed 's/ 4[0-9];/ 01;/; s/;4[0-9];/;01;/g; s/;4[0-9] /;01 /' | \
    dircolors /dev/stdin)"

eval "$(fzf --zsh)"

export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#d0d0d0,fg+:#d0d0d0,bg:#1e1e1e,bg+:#3f3f3f
  --color=hl:#5f87af,hl+:#5fd7ff,info:#afaf87,marker:#87ff00
  --color=prompt:#d7005f,spinner:#af5fff,pointer:#af5fff,header:#87afaf
  --color=gutter:#3f3f3f,border:#262626,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

autoload -Uz compinit
compinit

source /usr/share/google-cloud-sdk/completion.zsh.inc

complete -o nospace -C /usr/bin/tofu tofu

export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="\
$HOME/repositories/osinfra-io/platform-group/pt-ai-context,\
$HOME/repositories/osinfra-io/platform-group/arche/pt-arche-ai-context,\
$HOME/repositories/osinfra-io/platform-group/logos/pt-logos-ai-context,\
$HOME/repositories/osinfra-io/platform-group/corpus/pt-corpus-ai-context,\
$HOME/repositories/osinfra-io/platform-group/pneuma/pt-pneuma-ai-context,\
$HOME/repositories/osinfra-io/platform-group/ekklesia/pt-ekklesia-ai-context,\
$HOME/repositories/osinfra-io/platform-group/techne/pt-techne-ai-context"

echo "test" | gpg --pinentry-mode loopback --passphrase "not a real passphrase" --clearsign > /dev/null 2>&1
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
mkdir -p ${HOME}/.opentofu.d/plugin-cache
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
