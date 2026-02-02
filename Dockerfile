FROM ghcr.io/lingdie/devbox-runtime-expt/debian-12.6:v2.5.0-rc.4-en-us

# Evitar prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

USER root

# Instalar dependencias do sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instalar openclaw globalmente
RUN npm install -g openclaw@latest
RUN npm install -g bun
RUN npm install -g clawhub

# Copiar scripts de auto-approve e entrypoint
COPY --chown=devbox:devbox auto-approve.js /home/devbox/project
COPY --chown=devbox:devbox entrypoint.sh /home/devbox/project
COPY --chown=devbox:devbox openclaw.json /home/devbox/.openclaw

# Criar diretorios com permissoes corretas
RUN mkdir -p /home/devbox/.clawdbot /home/devbox/project/workspace && \
    chown -R devbox:devbox /home/devbox && \
    chmod +x /home/devbox/project/entrypoint.sh

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb; \
    dpkg -i google-chrome-stable_current_amd64.deb; \
    apt --fix-broken install -y

USER devbox
WORKDIR /home/devbox/project

RUN clawhub install openai-whisper; \
    clawhub install auto-updater; \
    clawhub install marketing-skills; \
    clawhub install kubectl; \
    clawhub install ralph-loops

# Configurar ambiente de producao
ENV NODE_ENV=production
ENV CLAWDBOT_GATEWAY_BIND=0.0.0.0

# Porta do gateway
EXPOSE 18789

# Volumes para persistencia
VOLUME ["/home/devbox/.clawdbot", "/home/devbox/project/workspace"]

# Comando de entrada
CMD ["/home/devbox/project/entrypoint.sh"]
