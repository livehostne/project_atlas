#!/bin/bash

# Inicia o serviço SSH
service ssh start

# Define a porta do SSH
SSH_PORT=2222

# Define o token do Ngrok diretamente
NGROK_AUTH_TOKEN="2AdQXydT77VZUxSzBqjwtMyC4xv_3HFqfbvtMdsvQwmT9xVJK"  # Substitua pelo seu token do Ngrok

# Verifica se o token do Ngrok foi configurado
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "Erro: NGROK_AUTH_TOKEN não foi configurado."
  exit 1
fi

# Configura o token de autenticação do Ngrok
ngrok config add-authtoken $NGROK_AUTH_TOKEN

# Inicia o Ngrok na porta do SSH
echo "Starting Ngrok..."
ngrok tcp $SSH_PORT > /dev/null &

# Aguarda o Ngrok inicializar
sleep 5

# Obtém a URL pública do Ngrok
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "tcp://[0-9a-zA-Z.]*:[0-9]*")

# Exibe a URL do Ngrok para acesso externo
echo "Access your SSH server using this URL: $NGROK_URL"

# Mantém o container em execução
tail -f /dev/null
