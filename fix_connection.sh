#!/bin/bash
set -e

echo "🚑 FIXING CONNECTIVITY (ERROR 522)..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Get Public IP
  MY_IP=$(curl -s ifconfig.me)
  echo "ℹ️  Server Public IP: $MY_IP"

  # 2. Fix Firewalld (The user-friendly firewall)
  echo "--- Configuring Firewalld ---"
  if command -v firewall-cmd &> /dev/null; then
      sudo systemctl start firewalld
      sudo firewall-cmd --permanent --add-port=80/tcp
      sudo firewall-cmd --permanent --add-port=443/tcp
      sudo firewall-cmd --permanent --add-service=http
      sudo firewall-cmd --permanent --add-service=https
      sudo firewall-cmd --reload
      echo "✅ Firewalld Updated"
  else
      echo "⚠️ Firewalld not found."
  fi

  # 3. Fix IPtables (The deep OS firewall - Oracle often blocks here)
  echo "--- Configuring IPtables ---"
  # Flush existing input rules to be safe (careful) - actually, let's just INSERT accept rules at top
  sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
  # Save them if possible
  sudo service iptables save 2>/dev/null || true
  # For Oracle Linux specifically:
  sudo netfilter-persistent save 2>/dev/null || true
  
  echo "✅ IPtables Updated"

  # 4. Ensure Nginx is actively listening
  echo "--- Checking Nginx ---"
  sudo systemctl restart nginx
  
  # 5. Local Test
  echo "--- Local Verification ---"
  curl -I http://localhost
  
  echo "🎉 FIX COMPLETE. Port 80 should be open."
EOF
