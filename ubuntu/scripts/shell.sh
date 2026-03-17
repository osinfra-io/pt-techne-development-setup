#!/usr/bin/env bash

set -e

cd ~

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Zsh

command -v zsh | sudo tee -a /etc/shells

# Vim

cat << EOF > ~/.vimrc
set visualbell

filetype plugin indent on
syntax on
EOF

# GitHub extensions

# For some reason we need to authenticate to GitHub to install extensions

# gh extension install github/gh-copilot github/gh-projects actions/gh-actions-cache advanced-security/gh-sbom

# Oh My Zsh

if [ ! -f ~/.oh-my-zsh/oh-my-zsh.sh ]; then
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# Shell setup

if [ -f ~/.zshrc ]; then
  cp ~/.zshrc ~/.zshrc-"$(date +"%Y%m%d_%H%M%S")".bak
fi

# Comment out default plugins

sed -i '/^plugins=(git)$/s/^/#/' ~/.zshrc

cat << 'EOF' >> ~/.zshrc
alias gpg-passphrase="echo "test" | gpg --clearsign > /dev/null 2>&1"

export GOOGLE_AUTH_SUPPRESS_CREDENTIALS_WARNINGS=true
export GPG_TTY=$TTY
export EDITOR=vim

zstyle ':completion::complete:*' use-cache 1

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.exports ]] || source ~/.exports

source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/linuxbrew/.linuxbrew/opt/powerlevel10k/share/powerlevel10k/powerlevel10k.zsh-theme

unsetopt correct_all
setopt correct

eval "$(gh copilot alias -- zsh)"
eval "$(fzf --zsh)"
EOF

echo -e "plugins=(git terraform gcloud docker kubectl helm zsh-autosuggestions)\n$(cat ~/.zshrc)" > ~/.zshrc
echo -e "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"\n$(cat ~/.zshrc)" > ~/.zshrc
echo -e "export PATH=\$HOME/bin:\$PATH\n$(cat ~/.zshrc)" > ~/.zshrc

# Create update script

mkdir -p ~/bin
cat << 'EOF' > ~/bin/update.zsh
#!/usr/bin/env zsh

source ~/.zshrc

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
cd ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
git pull
EOF

chmod 755 ~/bin/update.zsh
