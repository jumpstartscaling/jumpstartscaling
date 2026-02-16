#!/bin/bash
# NUCLEAR RESET & VALIDATION

echo "🔍 CHECKING SELINUX..."
sudo setenforce 0 2>/dev/null
echo "SELinux: $(getenforce)"

echo "💀 KILLING ZOMBIES..."
sudo systemctl stop cloudflared
sudo pkill -9 cloudflared
# Check if any left
ps aux | grep cloudflared | grep -v grep

echo "📝 VALIDATING YAML..."
# Simple python yaml check
cat << PY > check_yaml.py
import sys, yaml
try:
    with open('/etc/cloudflared/config.yml', 'r') as f:
        print(yaml.safe_dump(yaml.safe_load(f)))
    print("YAML_OK")
except Exception as e:
    print(f"YAML_ERROR: {e}")
PY
sudo pip3 install pyyaml > /dev/null 2>&1
python3 check_yaml.py

echo "🚀 RESTARTING SERVICE..."
# RE-WRITE CONFIG TO BE SAFE (Spaces, not tabs)
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

sudo systemctl restart cloudflared
sleep 5
sudo systemctl status cloudflared --no-pager

echo "📡 CHECKING CONNECTION..."
# Check if tunnel is actually connected (logs)
sudo journalctl -u cloudflared -n 10 --no-pager
