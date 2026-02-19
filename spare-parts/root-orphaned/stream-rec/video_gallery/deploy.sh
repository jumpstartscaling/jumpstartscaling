#!/bin/bash
# Deploy Video Gallery to Oracle Server
# Run from the stream-rec directory

set -e

SERVER="193.122.168.215"
USER="opc"
REMOTE_DIR="/home/opc/video_gallery"

echo "📦 Deploying Video Gallery..."

# Create directory on server
ssh $USER@$SERVER "mkdir -p $REMOTE_DIR"

# Copy files
scp -r video_gallery/* $USER@$SERVER:$REMOTE_DIR/

# Build and run on server
ssh $USER@$SERVER << 'EOF'
cd /home/opc/video_gallery

# Stop existing container if running
docker stop video-gallery 2>/dev/null || true
docker rm video-gallery 2>/dev/null || true

# Build new image
docker build -t video-gallery .

# Run container
docker run -d \
    --name video-gallery \
    --restart unless-stopped \
    -p 8888:8888 \
    -v /home/opc/stream-rec/downloads:/opt/records \
    -e VIDEOS_DIR=/opt/records \
    video-gallery

echo "✅ Video Gallery deployed successfully!"
echo "🌐 Access at: http://193.122.168.215:8888/"
EOF
