#!/bin/bash

echo "🔧 Switching to DEV MODE (instant changes, no rebuild needed)"
echo "=============================================================="

ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling

# Stop production build
pm2 stop jumpstartscaling
pm2 delete jumpstartscaling

# Start in dev mode
pm2 start npm --name "jumpstartscaling-dev" -- run dev -- --port 8100 --host 0.0.0.0
pm2 save

echo ""
echo "✅ Dev mode active!"
echo "Now just sync source files and changes appear instantly (no rebuild)"
EOF

echo ""
echo "To sync source files after making changes:"
echo "  rsync -avz --exclude 'node_modules' --exclude 'dist' sites/jumpstartscaling/src/ opc@150.136.117.198:~/sites/jumpstartscaling/src/"
