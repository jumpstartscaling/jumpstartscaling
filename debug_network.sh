#!/bin/bash
echo "--- DEBUG NETWORK START ---" > ~/debug_proof.txt
date >> ~/debug_proof.txt

# 1. Internal Check (Localhost)
echo "1. Checking Localhost (127.0.0.1:8100)..." >> ~/debug_proof.txt
curl -I -m 2 http://127.0.0.1:8100 >> ~/debug_proof.txt 2>&1 || echo "FAIL" >> ~/debug_proof.txt

# 2. Get Public IP
MY_IP=$(curl -s ifconfig.me)
echo "Public IP detected: $MY_IP" >> ~/debug_proof.txt

# 3. External Loopback Check (Can I talk to myself?)
echo "2. Checking Public IP ($MY_IP:80)..." >> ~/debug_proof.txt
curl -I -m 2 http://$MY_IP >> ~/debug_proof.txt 2>&1 || echo "FAIL - Connection Refused / Timed Out" >> ~/debug_proof.txt

echo "3. Checking Public IP ($MY_IP:443)..." >> ~/debug_proof.txt
curl -k -I -m 2 https://$MY_IP >> ~/debug_proof.txt 2>&1 || echo "FAIL" >> ~/debug_proof.txt

# 4. Check Configured Firewalls
echo "--- Firewall States ---" >> ~/debug_proof.txt
echo "IPtables Rules:" >> ~/debug_proof.txt
sudo iptables -L -n | grep 80 >> ~/debug_proof.txt 2>&1

echo "Firewalld State:" >> ~/debug_proof.txt
sudo firewall-cmd --state >> ~/debug_proof.txt 2>&1
sudo firewall-cmd --list-all >> ~/debug_proof.txt 2>&1

echo "--- Netstat ---" >> ~/debug_proof.txt
sudo netstat -tulpn | grep nginx >> ~/debug_proof.txt 2>&1

echo "--- DEBUG NETWORK END ---" >> ~/debug_proof.txt
