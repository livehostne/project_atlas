#!/bin/bash

# Define o token do Ngrok diretamente
NGROK_AUTH_TOKEN="2AdQXydT77VZUxSzBqjwtMyC4xv_3HFqfbvtMdsvQwmT9xVJK"  # Substitua pelo seu token do Ngrok

# Verifica se o token do Ngrok foi configurado
if [ -z "$NGROK_AUTH_TOKEN" ]; then
  echo "Erro: NGROK_AUTH_TOKEN não foi configurado."
  exit 1
fi

# Configura o token de autenticação do Ngrok
ngrok config add-authtoken $NGROK_AUTH_TOKEN

# Inicia o Ngrok para o tmate
echo "Starting Ngrok..."
ngrok tcp 4000 > /dev/null &

# Inicia a aplicação tmate (sem SSH)
echo "Starting tmate session..."
tmate -S /tmp/tmate.sock new-session -d

# Exibe a URL do tmate para acesso externo
TMATE_URL=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' | sed 's/^/ssh /')
echo "Access your terminal via tmate using: $TMATE_URL"

# Aguarda o Ngrok inicializar e obter a URL
sleep 5

# Obtém a URL pública do Ngrok
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "tcp://[0-9a-zA-Z.]*:[0-9]*")

# Exibe a URL do Ngrok para acessar a sessão tmate
echo "Access your tmate session using this URL: $NGROK_URL"

# Mantém o container em execução
tail -f /dev/null
