FROM ghcr.io/labring-actions/devbox-runtime-expt/ubuntu-22.04:v2.5.0-rc.2-en-us

# Evitar prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias do sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instalar clawdbot globalmente
RUN npm install -g clawdbot

# Copiar scripts de auto-approve e entrypoint
COPY --chown=clawdbot:clawdbot auto-approve.js /home/clawdbot/
COPY --chown=clawdbot:clawdbot entrypoint.sh /home/clawdbot/

# Criar usuario nao-root
RUN useradd -m -s /bin/bash clawdbot

# Criar diretorios com permissoes corretas
RUN mkdir -p /home/clawdbot/.clawdbot /home/clawdbot/workspace && \
    chown -R clawdbot:clawdbot /home/clawdbot && \
    chmod +x /home/clawdbot/entrypoint.sh

# Criar configuração inicial com allowInsecureAuth
RUN echo '{"gateway":{"controlUi":{"enabled":true,"allowInsecureAuth":true}},"messages":{"ackReactionScope":"group-mentions"},"agents":{"defaults":{"maxConcurrent":4,"subagents":{"maxConcurrent":8},"compaction":{"mode":"safeguard"}}},"plugins":{"entries":{"telegram":{"enabled":true}}}}' > /home/clawdbot/.clawdbot/clawdbot.json && \
    chown clawdbot:clawdbot /home/clawdbot/.clawdbot/clawdbot.json

USER clawdbot
WORKDIR /home/clawdbot

# Configurar ambiente de producao
ENV NODE_ENV=production
ENV CLAWDBOT_GATEWAY_BIND=0.0.0.0

# Porta do gateway
EXPOSE 18789

# Volumes para persistencia
VOLUME ["/home/clawdbot/.clawdbot", "/home/clawdbot/workspace"]

# Comando de entrada
CMD ["/home/clawdbot/entrypoint.sh"]
