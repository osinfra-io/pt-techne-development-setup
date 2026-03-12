FROM mcr.microsoft.com/vscode/devcontainers/base:2.1.7-ubuntu22.04

# We need to run this as root then switch to vscode vs. having everything in the same RUN command

RUN chsh vscode -s /usr/bin/zsh

USER vscode

COPY --chown=vscode:vscode setup.sh /tmp/setup.sh

RUN ./tmp/setup.sh && \
	rm /tmp/setup.sh

# Reasonable defaults for Powerlevel10k

COPY --chown=vscode:vscode .p10k.zsh /home/vscode/.p10k.zsh

CMD ["zsh"]
