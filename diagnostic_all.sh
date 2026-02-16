#!/bin/bash
OUT=~/diag_v2.txt
echo "--- 1. SERVICE STATUS ---" > $OUT
sudo systemctl status cloudflared --no-pager >> $OUT 2>&1

echo -e "\n--- 2. CONFIG.YML ---" >> $OUT
sudo cat /etc/cloudflared/config.yml >> $OUT 2>&1

echo -e "\n--- 3. DNS CHECK (Local) ---" >> $OUT
dig +short jumpstartscaling.com >> $OUT 2>&1

echo -e "\n--- 4. LOGS (Last 20) ---" >> $OUT
sudo journalctl -u cloudflared -n 20 --no-pager >> $OUT 2>&1

echo -e "\n--- 5. PROCESS LIST ---" >> $OUT
ps aux | grep cloudflared >> $OUT 2>&1
