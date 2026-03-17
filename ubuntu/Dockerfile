FROM mcr.microsoft.com/vscode/devcontainers/base:2.1.7-ubuntu22.04

# We need to run this as root then switch to vscode vs. having everything in the same RUN command

RUN chsh vscode -s /usr/bin/zsh

USER vscode

# Layer: apt packages (changes rarely)

COPY --chown=vscode:vscode scripts/apt.sh /tmp/apt.sh
RUN /tmp/apt.sh && rm /tmp/apt.sh

# Layer: Homebrew bootstrap (changes rarely)

COPY --chown=vscode:vscode scripts/homebrew.sh /tmp/homebrew.sh
RUN /tmp/homebrew.sh && rm /tmp/homebrew.sh

# Layer: brew tools (changes when tool list changes)

COPY --chown=vscode:vscode scripts/tools.sh /tmp/tools.sh
RUN /tmp/tools.sh && rm /tmp/tools.sh

# Layer: Google Cloud SDK (changes when gcloud version changes)

COPY --chown=vscode:vscode scripts/gcloud.sh /tmp/gcloud.sh
RUN /tmp/gcloud.sh && rm /tmp/gcloud.sh

# Layer: shell config (changes most often)

COPY --chown=vscode:vscode scripts/shell.sh /tmp/shell.sh
RUN /tmp/shell.sh && rm /tmp/shell.sh

# Reasonable defaults for Powerlevel10k

COPY --chown=vscode:vscode .p10k.zsh /home/vscode/.p10k.zsh

CMD ["zsh"]
