import subprocess
from flask import Flask, Response, stream_with_context
import time

app = Flask(__name__)

# URL do stream DASH
STREAM_URL = 'https://abc.embedmax.site/sportv1/index.mpd'  # Substitua pela URL real
LOG_FILE = './stream_log.txt'  # Arquivo de log para monitoramento

# User-Agent simulado
USER_AGENT = "Mozilla/5.0 (Linux; Android 13; Redmi Note 13 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.5672.92 Mobile Safari/537.36"

# Função para registrar logs
def log_message(message):
    with open(LOG_FILE, 'a') as log_file:
        log_file.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} - {message}\n")
        log_file.flush()

# Função para verificar se o FFmpeg está instalado
def check_ffmpeg():
    if subprocess.call(['which', 'ffmpeg'], stdout=subprocess.PIPE, stderr=subprocess.PIPE):
        log_message("FFmpeg não está instalado. Por favor, instale o FFmpeg.")
        exit(1)
    log_message("FFmpeg está instalado.")

@app.route('/stream.ts')
def stream_ts():
    # Comando FFmpeg para capturar e converter o stream para TS
    command = [
        'ffmpeg',
        '-user_agent', USER_AGENT,  # Define o User-Agent
        '-i', STREAM_URL,          # URL de entrada (DASH)
        '-c:v', 'copy',            # Copia o vídeo sem re-encode
        '-c:a', 'copy',            # Copia o áudio sem re-encode
        '-f', 'mpegts',            # Define o formato de saída para TS
        'pipe:1'                   # Envia a saída para o stdout
    ]

    log_message("Iniciando o processo FFmpeg para TS.")
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def generate():
        try:
            while True:
                chunk = process.stdout.read(1024)
                if not chunk:
                    log_message("O processo FFmpeg não retornou mais dados.")
                    break
                yield chunk
        finally:
            process.terminate()  # Garante que o FFmpeg seja encerrado
            log_message("Processo FFmpeg encerrado para TS.")

    return Response(stream_with_context(generate()), content_type='video/MP2T')

@app.route('/stream.m3u8')
def stream_m3u8():
    # Comando FFmpeg para capturar e converter o stream para HLS
    command = [
        'ffmpeg',
        '-user_agent', USER_AGENT,  # Define o User-Agent
        '-i', STREAM_URL,          # URL de entrada (DASH)
        '-c:v', 'copy',            # Copia o vídeo sem re-encode
        '-c:a', 'copy',            # Copia o áudio sem re-encode
        '-f', 'hls',               # Define o formato de saída para HLS
        '-hls_time', '10',         # Define a duração de cada segmento
        '-hls_list_size', '0',     # Gera todos os segmentos
        '-hls_flags', 'delete_segments',
        'pipe:1'                   # Envia a saída para o stdout
    ]

    log_message("Iniciando o processo FFmpeg para M3U8.")
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    def generate():
        try:
            while True:
                chunk = process.stdout.read(1024)
                if not chunk:
                    log_message("O processo FFmpeg não retornou mais dados.")
                    break
                yield chunk
        finally:
            process.terminate()  # Garante que o FFmpeg seja encerrado
            log_message("Processo FFmpeg encerrado para M3U8.")

    return Response(stream_with_context(generate()), content_type='application/vnd.apple.mpegurl')

if __name__ == '__main__':
    check_ffmpeg()
    app.run(host='0.0.0.0', port=80, debug=True)
