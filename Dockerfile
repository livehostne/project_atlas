# Usa a imagem do Debian 10 como base
FROM debian:10

# Atualiza os pacotes e instala tmate, wget, curl e unzip
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    unzip \
    tmate \
    && apt-get clean

# Configura o diretório de trabalho para /app
WORKDIR /app

# Baixa e instala o Ngrok
RUN wget -q -O /tmp/ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip && \
    unzip /tmp/ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok

# Copia o script de inicialização para o diretório de trabalho
COPY start.sh ./start.sh
RUN chmod +x ./start.sh

# Expõe a porta do tmate (não necessário, mas deixo por clareza)
EXPOSE 4000

# Comando para iniciar os serviços
CMD ["./start.sh"]
