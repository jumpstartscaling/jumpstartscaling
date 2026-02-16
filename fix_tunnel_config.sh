#!/bin/bash
echo "🔧 FIXING CLOUDFLARED CONFIG..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # Backup existing
  sudo cp /etc/cloudflared/config.yml /etc/cloudflared/config.yml.bak
  
  # Rewrite config to ONLY contain ingress (Token mode)
  sudo tee /etc/cloudflared/config.yml > /dev/null << YAML
# Tunnel UUID and Credentials are handled by the Service Token
# We only define Ingress here.

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

  echo "Restarting Cloudflared..."
  sudo systemctl restart cloudflared
  sudo systemctl status cloudflared --no-pager
  
  echo "✅ Config corrected for Token Mode."
EOF
