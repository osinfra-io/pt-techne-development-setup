# Setup scripts for local Infrastructure as Code (IaC) development

[![Dependabot](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-techne-development-setup/dependabot.yml?style=for-the-badge&logo=github&color=2088FF&label=Dependabot)](https://github.com/osinfra-io/pt-techne-development-setup/actions/workflows/dependabot.yml) [![Datadog Security Enabled](https://img.shields.io/badge/Datadog%20Security-Enabled-632CA6?style=for-the-badge&logo=datadog)](https://app.datadoghq.com/security/code-security/repositories?repository_id=pt-techne-development-setup)

## Purpose

This repository builds the shared Ubuntu development image and provides the host setup script used by platform engineers. The setup installs the platform toolchain, including OpenTofu, Google Cloud CLI, kubectl, Helm, Istio CLI, GitHub CLI, Copilot CLI, pre-commit, k9s, Homebrew, Zsh, and shell configuration.

Use the [platform Codespace](https://github.com/osinfra-io/pt-techne-opentofu-codespace) for the lowest-friction managed environment. Use the Ubuntu script for a dedicated Linux workstation or WSL environment where you control system packages.

## Ubuntu Setup

The following optional command grants the current user passwordless administrator access. Use it only on a dedicated development machine whose security policy permits it:

```none
 echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo EDITOR='tee -a' visudo
 ```

Run the setup script:

```none
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/osinfra-io/pt-techne-development-setup/main/ubuntu/setup.sh)"
```

Change your default shell to Zsh and exit.

```none
chsh -s /home/linuxbrew/.linuxbrew/bin/zsh; exit
```

Once complete, you can stay current by running the generated update script.

```none
~/bin/update.zsh
```

### Local Development

To test local changes without pushing to GitHub, set `LOCAL=true`:

```none
LOCAL=true bash ubuntu/setup.sh
```
