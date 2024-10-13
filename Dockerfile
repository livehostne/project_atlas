# Usar uma imagem base do Python com FFmpeg
FROM jrottenberg/ffmpeg:4.4-scratch

# Defina o diretório de trabalho
WORKDIR /app

# Copie os arquivos do projeto para a imagem
COPY . .

# Instale as dependências
RUN pip install --no-cache-dir -r requirements.txt

# Comando para iniciar o aplicativo Flask
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:10000"]
