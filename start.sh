#!/bin/bash

# Define o token do Ngrok diretamente
NGROK_AUTH_TOKEN="2AdQXydT77VZUxSzBqjwtMyC4xv_3HFqfbvtMdsvQwmT9xVJK"  # Substitua pelo seu token do Ngrok

# Define uma senha simples para controlar o acesso
AUTHORIZED_PASSWORD="9agos2010"  # Altere para a senha desejada

# Função para verificar a senha
check_password() {
    read -sp "Digite a senha para acessar a sessão tmate: " input_password
    echo
    if [ "$input_password" != "$AUTHORIZED_PASSWORD" ]; then
        echo "Senha incorreta. Acesso negado."
        exit 1
    else
        echo "Acesso concedido."
    fi
}

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

# Pede a senha para acessar a URL do tmate
check_password

# Exibe a URL do tmate para acesso externo
TMATE_URL=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' | sed 's/^/ssh /')
echo "Acesse seu terminal via tmate usando: $TMATE_URL"

# Inicia o servidor nginx no fundo
echo "Starting nginx server..."
service nginx start

# Aguarda o Ngrok inicializar e obter a URL
sleep 5

# Obtém a URL pública do Ngrok
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "tcp://[0-9a-zA-Z.]*:[0-9]*")

# Exibe a URL do Ngrok para acessar a sessão tmate
echo "Acesse sua sessão tmate usando esta URL do Ngrok: $NGROK_URL"

# Mantém o container em execução
tail -f /dev/null
