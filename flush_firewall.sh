#!/bin/bash
set -e

echo "🔥 EXECUTING TOTAL FIREWALL FLUSH..."

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
  # 1. Stop Firewalld entirely (Temporary test)
  echo "Stopping Firewalld..."
  sudo systemctl stop firewalld || true
  sudo systemctl disable firewalld || true

  # 2. FLUSH IPtables (The Nuclear Option)
  echo "Flushing IPtables..."
  sudo iptables -F
  sudo iptables -X
  sudo iptables -t nat -F
  sudo iptables -t nat -X
  sudo iptables -t mangle -F
  sudo iptables -t mangle -X
  
  # 3. Set Default Policies to ACCEPT (Allow Everything)
  echo "Setting Default Policy to ACCEPT..."
  sudo iptables -P INPUT ACCEPT
  sudo iptables -P FORWARD ACCEPT
  sudo iptables -P OUTPUT ACCEPT

  # 4. Oracle Linux Specific: Flush IDM/NFTables if present
  sudo nft flush ruleset 2>/dev/null || true

  echo "✅ FIREWALLS DISABLED. Server is WIDE OPEN."
  
  # 5. Verify Listener
  echo "Verifying Nginx is listening..."
  sudo netstat -tulpn | grep 80
EOF
