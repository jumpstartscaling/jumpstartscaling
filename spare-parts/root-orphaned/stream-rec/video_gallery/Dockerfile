FROM python:3.11-slim

# Install FFmpeg for video conversion and git for cloning
RUN apt-get update && apt-get install -y ffmpeg git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python dependencies and TikTokDownloader
RUN pip install --no-cache-dir flask gunicorn yt-dlp && \
    git clone https://github.com/JoeanAmier/TikTokDownloader.git /app/tiktok-downloader && \
    cd /app/tiktok-downloader && \
    pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .
COPY templates templates/

EXPOSE 8888

# Run with Gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:8888", "--workers", "2", "--threads", "4", "app:app"]
