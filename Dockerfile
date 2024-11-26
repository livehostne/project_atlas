# Usa a imagem do Debian 10 como base
FROM debian:10

# Atualiza os pacotes e instala o SSH, wget, curl e unzip
RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    curl \
    unzip \
    && apt-get clean

# Configura o diretório de trabalho para /app
WORKDIR /app

# Configura o SSH para rodar em uma porta diferente (exemplo: 2222)
RUN sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config

# Gera as chaves do SSH se ainda não existirem
RUN mkdir -p /run/sshd && ssh-keygen -A

# Cria um usuário para o SSH com senha
RUN useradd -m -s /bin/bash sshuser && echo "sshuser:sshpassword" | chpasswd

# Baixa e instala o Ngrok
RUN wget -q -O /tmp/ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip && \
    unzip /tmp/ngrok.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ngrok

# Copia o script de inicialização para o diretório de trabalho
COPY start.sh ./start.sh
RUN chmod +x ./start.sh

# Expõe a porta do SSH personalizada
EXPOSE 2222

# Comando para iniciar os serviços
CMD ["./start.sh"]
