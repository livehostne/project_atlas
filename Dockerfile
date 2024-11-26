# Usa a imagem do Debian 10 como base
FROM debian:10

# Atualiza os pacotes e instala tmate, nginx, wget, curl e unzip
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    tmate \
    nginx \
    && apt-get clean

# Configura o diretório de trabalho para /app
WORKDIR /app

# Baixa e instala o Ngrok
RUN wget -q -O /tmp/ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip && \
    unzip /tmp/ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok

# Configura o Nginx para rodar em segundo plano
RUN echo "server { listen 80; root /app; index index.html; }" > /etc/nginx/sites-available/default

# Copia o script de inicialização para o diretório de trabalho
COPY start.sh ./start.sh
RUN chmod +x ./start.sh

# Expõe a porta do servidor web e do tmate (4000)
EXPOSE 80 4000

# Comando para iniciar os serviços
CMD ["./start.sh"]
