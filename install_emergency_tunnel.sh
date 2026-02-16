#!/bin/bash
echo "🚀 INSTALLING EMERGENCY TUNNEL ON SERVER..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  set -e
  
  # 1. STOP & CLEAN
  echo "Stopping old services..."
  sudo systemctl stop cloudflared || true
  sudo cloudflared service uninstall || true
  sudo pkill -f cloudflared || true
  
  # 2. INSTALL
  echo "Installing new service..."
  if [ ! -f ~/FINAL_TOKEN.txt ]; then
    echo "❌ CRITICAL: FINAL_TOKEN.txt not found!"
    exit 1
  fi
  
  TOKEN=$(cat ~/FINAL_TOKEN.txt)
  sudo cloudflared service install "$TOKEN"
  
  # 3. CONFIGURE INGRESS
  echo "Writing config.yml..."
  sudo tee /etc/cloudflared/config.yml > /dev/null << YAML
ingress:
  - hostname: jumpstartscaling.com
    service: http://localhost:8100
  - hostname: www.jumpstartscaling.com
    service: http://localhost:8100
  - hostname: n8n.jumpstartscaling.com
    service: http://localhost:5678
  - hostname: cockpit.jumpstartscaling.com
    service: http://localhost:9090
  - hostname: api.jumpstartscaling.com
    service: http://localhost:8100
  - service: http_status:404
YAML

  # 4. RESTART
  echo "Restarting service..."
  sudo systemctl restart cloudflared
  sudo systemctl status cloudflared --no-pager
  
  echo "✅ TUNNEL INSTALLED & RUNNING!"
EOF
