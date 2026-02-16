#!/bin/bash
echo "🛡️ UNIVERSAL FIX INITIATED..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  set -e
  
  # 1. DISABLE SELinux (Common cause of 'Refused' on Oracle Linux)
  echo "[1/5] Setting SELinux to Permissive..."
  sudo setenforce 0 || true
  # Persist it
  sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config || true

  # 2. DISABLE Firewalld
  echo "[2/5] Stopping Firewalld..."
  sudo systemctl stop firewalld || true
  sudo systemctl disable firewalld || true

  # 3. FLUSH IPtables
  echo "[3/5] Flushing IPtables..."
  sudo iptables -F
  sudo iptables -P INPUT ACCEPT
  sudo iptables -P FORWARD ACCEPT
  sudo iptables -P OUTPUT ACCEPT

  # 4. RESTART Nginx (Force Binding)
  echo "[4/5] Restarting Nginx..."
  # Ensure config is valid
  sudo nginx -t
  sudo systemctl restart nginx
  
  # 5. VERIFY Localhost
  echo "[5/5] Testing Localhost..."
  curl -I http://127.0.0.1 | head -n 1
  
  echo "✅ UNIVERSAL FIX COMPLETE. Server is Wide Open."
EOF
