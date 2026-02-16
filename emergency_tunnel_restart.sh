#!/bin/bash
# Emergency tunnel diagnostic and restart

echo "STOPPING ALL TUNNEL SERVICES"
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'STOP'
sudo systemctl stop cloudflared
sudo pkill -9 cloudflared
sleep 2
ps aux | grep cloudflared | grep -v grep && echo "WARNING: Process still running" || echo "All processes stopped"
STOP

echo ""
echo "GETTING CURRENT TUNNEL INFO FROM DNS"
python3 << 'PY'
import requests
ZONE_ID = "f1e606b93260b3e12a939612c12c6370"
TOKEN = "A9npywa0ssv3j9XNz2zOGtvTtkmoQ17YOyeE2WXG"
HEADERS = {"Authorization": f"Bearer {TOKEN}"}

# Get DNS tunnel ID
resp = requests.get(f"https://api.cloudflare.com/client/v4/zones/{ZONE_ID}/dns_records", headers=HEADERS)
for r in resp.json()['result']:
    if r['name'] == 'jumpstartscaling.com' and 'cfargotunnel' in r['content']:
        tunnel_id = r['content'].split('.')[0]
        print(f"DNS_TUNNEL_ID={tunnel_id}")
        with open('/tmp/dns_tunnel_id.txt', 'w') as f:
            f.write(tunnel_id)
        break
PY

DNS_TUNNEL=$(cat /tmp/dns_tunnel_id.txt 2>/dev/null || echo "UNKNOWN")
echo "DNS points to tunnel: $DNS_TUNNEL"

echo ""
echo "READING SERVER TOKEN"
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 'cat ~/FINAL_TOKEN.txt 2>/dev/null || echo "NO_TOKEN_FILE"' > /tmp/server_token.txt
SERVER_TOKEN=$(cat /tmp/server_token.txt)

if [ "$SERVER_TOKEN" = "NO_TOKEN_FILE" ]; then
    echo "ERROR: No token file on server, need to regenerate"
    exit 1
fi

echo "Token found (length: ${#SERVER_TOKEN})"

echo ""
echo "REINSTALLING TUNNEL SERVICE"
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << INSTALL
sudo cloudflared service uninstall 2>/dev/null || true
sudo cloudflared service install "$SERVER_TOKEN"

# Write clean config
sudo tee /etc/cloudflared/config.yml > /dev/null << 'YAML'
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

echo "Starting service..."
sudo systemctl daemon-reload
sudo systemctl restart cloudflared
sudo systemctl enable cloudflared

sleep 8

echo "=== SERVICE STATUS ==="
sudo systemctl is-active cloudflared && echo "SERVICE: ACTIVE" || echo "SERVICE: FAILED"

echo ""
echo "=== CHECKING LOGS FOR ERRORS ==="
sudo journalctl -u cloudflared -n 25 --no-pager | grep -i "error\|fail\|registered" || echo "No clear status in logs"

echo ""
echo "=== PROCESS CHECK ==="
ps aux | grep cloudflared | grep -v grep || echo "No process found"
INSTALL

echo ""
echo "TESTING FROM LOCAL MACHINE"
sleep 5
curl -I https://jumpstartscaling.com 2>&1 | head -5

echo ""
echo "DONE - Check above output for errors"
