# Setup scripts for local Infrastructure as Code (IaC) development

[![Dependabot](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-techne-development-setup/dependabot.yml?style=for-the-badge&logo=github&color=2088FF&label=Dependabot)](https://github.com/osinfra-io/pt-techne-development-setup/actions/workflows/dependabot.yml) [![Datadog Security Enabled](https://img.shields.io/badge/Datadog%20Security-Enabled-632CA6?style=for-the-badge&logo=datadog)](https://app.datadoghq.com/security/code-security/repositories?repository_id=pt-techne-development-setup)

## Goals

When you invest in Infrastructure as Code (IaC), you will find that onboarding developers takes time and can be confusing for people new to development, limiting contributions.

- Standardized IaC developer environments
- Simplify onboarding so new IaC developers can contribute easier

## Prerequisites

Before running the setup script, ensure you have:

- **Operating System**: Ubuntu 22.04 or 24.04 (other Debian-based distributions may work)
- **Internet Connection**: Required to download packages and tools
- **Disk Space**: At least 5GB of free disk space for all tools and dependencies
- **User Permissions**: Sudo access (you will be prompted for your password during installation)
- **curl**: Pre-installed on most Ubuntu systems (`sudo apt install curl` if needed)

**Recommended for best experience:**

- Terminal with true color support for Powerlevel10k theme
- Nerd Font installed for proper icon rendering

## <img align="left" width="25" height="25" src="https://user-images.githubusercontent.com/1610100/196566203-0acc19c8-f1d9-4481-9424-24da28c53d99.png"> Ubuntu Setup

The setup script installs a complete IaC development environment including:

- **Homebrew** - Package manager for Linux
- **Google Cloud SDK** - gcloud CLI and GKE authentication plugin
- **Development Tools** - OpenTofu, kubectl, helm, istioctl, gh CLI, pre-commit, k9s, kubectx, opa, and more
- **Shell Environment** - Zsh with Oh My Zsh, Powerlevel10k theme, syntax highlighting, and autosuggestions

*The following step is optional but allows sudo access without entering a password.*

```none
 echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
 ```

Run the setup script:

```none
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/osinfra-io/pt-techne-development-setup/main/ubuntu/setup.sh)"
```

To test local changes without pushing to GitHub, set `LOCAL=true`:

```none
LOCAL=true bash ubuntu/setup.sh
```

Change your default shell to Zsh and exit.

```none
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh; exit
```

You will be prompted to set up Powerlevel10k when you start your terminal. Choose the options you like and go!

Once complete, you can stay current by running the generated update script.

```none
~/bin/update.zsh
```
