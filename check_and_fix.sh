#!/bin/bash
echo "🕵️‍♂️ DIAGNOSING REFUSAL..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Check Internal Nginx (Is it running?)
  echo "--- INTERNAL CURL ---"
  curl -I http://127.0.0.1
  
  # 2. Check Process
  echo "--- PROCESS ---"
  ps aux | grep nginx
  
  # 3. Stop Firewalld (Oracle's default REJECTS connections)
  echo "--- STOPPING FIREWALLD ---"
  sudo systemctl stop firewalld
  sudo systemctl disable firewalld
  
  # 4. Flush IPtables (Just in case)
  sudo iptables -F
  sudo iptables -P INPUT ACCEPT
  
  # 5. Check External Access (Can I talk to myself via Public IP?)
  MY_IP=$(curl -s ifconfig.me)
  echo "--- SELF-PUBLIC CURL ($MY_IP) ---"
  curl -I --connect-timeout 2 http://$MY_IP
EOF
