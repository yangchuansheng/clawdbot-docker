FROM ubuntu:22.04

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

# Instalar openclaw globalmente
RUN npm install -g openclaw@latest

# Copiar scripts de auto-approve e entrypoint
COPY --chown=openclaw:openclaw auto-approve.js /home/openclaw/
COPY --chown=openclaw:openclaw entrypoint.sh /home/openclaw/

# Criar usuario nao-root
RUN useradd -m -s /bin/bash openclaw

# Criar diretorios com permissoes corretas
RUN mkdir -p /home/openclaw/.openclaw /home/openclaw/workspace && \
    chown -R openclaw:openclaw /home/openclaw && \
    chmod +x /home/openclaw/entrypoint.sh

# Criar configuração inicial com allowInsecureAuth
RUN echo '{"gateway":{"controlUi":{"enabled":true,"allowInsecureAuth":true}},"messages":{"ackReactionScope":"group-mentions"},"agents":{"defaults":{"maxConcurrent":4,"subagents":{"maxConcurrent":8},"compaction":{"mode":"safeguard"}}},"plugins":{"entries":{"telegram":{"enabled":true}}}}' > /home/openclaw/.openclaw/openclaw.json && \
    chown openclaw:openclaw /home/openclaw/.openclaw/openclaw.json

USER openclaw
WORKDIR /home/openclaw

# Configurar ambiente de producao
ENV NODE_ENV=production
ENV openclaw_GATEWAY_BIND=0.0.0.0

# Porta do gateway
EXPOSE 18789

# Volumes para persistencia
VOLUME ["/home/openclaw/.openclaw", "/home/openclaw/workspace"]

# Comando de entrada
CMD ["/home/openclaw/entrypoint.sh"]
