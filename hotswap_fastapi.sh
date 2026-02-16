#!/bin/bash
# Hotswap FastAPI preview endpoint without full redeploy
set -e

echo "🔱 Hotswapping FastAPI Multi-Tenant Preview..."

# 1. Copy updated Python file to production
echo "📤 Uploading forever_connection.py..."
scp -i ~/.ssh/coolify_key \
  god_architect_local/forever_connection.py \
  root@72.61.15.216:/tmp/forever_connection.py

# 2. Move file into container
echo "📦 Moving file into container..."
ssh -i ~/.ssh/coolify_key root@72.61.15.216 \
  "docker cp /tmp/forever_connection.py god-mode-ic8gscgw0k4c8kgc4cs8sck4-034824382095:/app/god_architect_local/forever_connection.py"

# 3. Restart the FastAPI process
echo "🔄 Restarting FastAPI bridge..."
ssh -i ~/.ssh/coolify_key root@72.61.15.216 \
  "docker exec god-mode-ic8gscgw0k4c8kgc4cs8sck4-034824382095 pkill -f forever_connection.py || true"

sleep 2

# FastAPI will auto-restart via start-services.sh supervisor
echo "✅ FastAPI updated!"
echo ""
echo "🔍 Test preview endpoint:"
echo "http://spark.jumpstartscaling.com:8505/preview/masta.codes/home"
echo ""
echo "📋 Check if it's running:"
echo "ssh -i ~/.ssh/coolify_key root@72.61.15.216 \"docker logs god-mode-ic8gscgw0k4c8kgc4cs8sck4-034824382095 | tail -20\""
