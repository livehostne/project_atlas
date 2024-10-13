# Usar uma imagem base do Python
FROM python:3.10-slim

# Atualizar os pacotes e instalar FFmpeg
RUN apt-get update && apt-get install -y ffmpeg && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Defina o diretório de trabalho
WORKDIR /app

# Copie os arquivos do projeto para a imagem
COPY . .

# Instale as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Comando para iniciar o aplicativo Flask
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]
