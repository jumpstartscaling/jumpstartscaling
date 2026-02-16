#!/bin/bash
set -e

TOKEN="eyJvzCI6ImY1NGE... This is a placeholder, actual token is short in prompt, but I will use the one provided"
# Using the exact token provided by user:
USER_TOKEN="f54a1df62971e53f5420c113740fc08f6acac"

echo "🚇 Configuring Cloudflare Tunnel..."
echo "======================================"

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << EOF
  echo "--- 1. Stopping existing services ---"
  sudo systemctl stop cloudflared || true
  sudo cloudflared service uninstall || true
  
  # Kill any rogue processes
  sudo pkill -f cloudflared || true

  echo "--- 2. Installing new tunnel ---"
  # Try to install with the provided token
  # Note: The token provided (37 chars) seems short for a JWT, but we will attempt it.
  # If it fails, we will capture the output.
  
  if sudo cloudflared service install "$USER_TOKEN"; then
    echo "✅ Tunnel service installed successfully."
    sudo systemctl start cloudflared
    sudo systemctl status cloudflared --no-pager
  else
    echo "❌ Tunnel installation failed. The token might be invalid or expired."
    echo "   Token used: $USER_TOKEN"
    exit 1
  fi

  echo "--- 3. Verifying Local Service ---"
  # Ensure Next.js is running
  if curl -s http://localhost:8100 > /dev/null; then
    echo "✅ Next.js is active on port 8100"
  else
    echo "⚠️ Next.js does not seem to be responding on 8100. Restarting..."
    cd ~/jumpstart-next
    pm2 restart jumpstart-next
  fi
EOF
