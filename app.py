import subprocess
from flask import Flask, Response, stream_with_context
import os
import time

app = Flask(__name__)

# URL do stream usando o CORS Proxy
STREAM_URL = 'https://corsproxy.io/?http://h4tk.in:80/wellington123/wellington123/1568437'  # Substitua por sua URL real
LOG_FILE = './stream_log.txt'  # Arquivo de log para monitoramento

# Função para registrar logs
def log_message(message):
    with open(LOG_FILE, 'a') as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")
        log_file.flush()  # Garante que o log seja escrito imediatamente

# Função para verificar se o FFmpeg está instalado
def check_ffmpeg():
    if subprocess.call(['which', 'ffmpeg'], stdout=subprocess.PIPE, stderr=subprocess.PIPE):
        log_message("FFmpeg não está instalado. Por favor, instale o FFmpeg.")
        exit(1)
    log_message("FFmpeg está instalado.")

@app.route('/stream.ts')
def stream():
    # Comando FFmpeg para capturar o stream
    command = [
        'ffmpeg',
        '-reconnect', '1',
        '-reconnect_streamed', '1',
        '-reconnect_delay_max', '10',
        '-i', STREAM_URL,
        '-c:v', 'copy',  # Copia o vídeo sem re-encode
        '-c:a', 'copy',  # Copia o áudio sem re-encode
        '-f', 'mpegts',  # Formato de saída
        'pipe:1'  # Envia a saída para o stdout
    ]

    # Inicia o processo FFmpeg
    log_message("Iniciando o processo FFmpeg.")
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Função para gerar o stream
    def generate():
        try:
            while True:
                chunk = process.stdout.read(1024)
                if not chunk:
                    log_message("O processo FFmpeg não retornou mais dados.")
                    break
                yield chunk
        finally:
            process.stdout.close()
            process.stderr.close()
            process.wait()
            log_message("Processo FFmpeg encerrado.")

    # Verifica se houve erro no processo
    if process.returncode is not None:
        error_message = process.stderr.read().decode()
        log_message(f"Erro ao iniciar o FFmpeg: {error_message}")
        return "Erro ao iniciar o stream", 500

    # Retorna a resposta de streaming
    log_message("Streaming iniciado com sucesso.")
    return Response(stream_with_context(generate()), content_type='video/MP2T')

if __name__ == '__main__':
    check_ffmpeg()  # Verifica se o FFmpeg está instalado
    app.run(host='0.0.0.0', port=80, debug=True)  # Aceita conexões de qualquer IP
