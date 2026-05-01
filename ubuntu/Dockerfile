FROM mcr.microsoft.com/vscode/devcontainers/base:2.1.8-ubuntu24.04

USER vscode

# Layer: apt packages (changes rarely)

COPY --chown=vscode:vscode scripts/apt.sh /tmp/apt.sh
RUN /tmp/apt.sh && rm /tmp/apt.sh

# Layer: Homebrew bootstrap (changes rarely)

COPY --chown=vscode:vscode scripts/homebrew.sh /tmp/homebrew.sh
RUN /tmp/homebrew.sh && rm /tmp/homebrew.sh

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Layer: Google Cloud SDK (changes when gcloud version changes)

COPY --chown=vscode:vscode scripts/gcloud.sh /tmp/gcloud.sh
RUN /tmp/gcloud.sh && rm /tmp/gcloud.sh

# Layer: brew tools (changes when tool list changes)

COPY --chown=vscode:vscode scripts/tools.sh /tmp/tools.sh
RUN /tmp/tools.sh && rm /tmp/tools.sh

# Layer: shell config (changes most often)

COPY --chown=vscode:vscode scripts/shell.sh /tmp/shell.sh
RUN /tmp/shell.sh && rm /tmp/shell.sh

# Reasonable defaults for Powerlevel10k

COPY --chown=vscode:vscode .p10k.zsh /home/vscode/.p10k.zsh

# Reasonable defaults for Vim

COPY --chown=vscode:vscode .vimrc /home/vscode/.vimrc

# Reasonable defaults for k9s

COPY --chown=vscode:vscode k9s/ /home/vscode/.config/k9s/

# Healthcheck to verify the container is functional
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
	CMD zsh -c 'exit 0' || exit 1

CMD ["zsh"]
