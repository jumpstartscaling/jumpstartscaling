#!/bin/bash
set -x  # Print commands as they execute

echo "=== FULL DEPLOYMENT WITH DIAGNOSTICS ==="
date

echo ""
echo "=== STEP 1: Sync ALL source files ===" 
rsync -avz --delete \
  --exclude 'node_modules' \
  --exclude 'dist' \
  --exclude '.astro' \
  sites/jumpstartscaling/src/ \
  opc@150.136.117.198:~/sites/jumpstartscaling/src/

echo ""
echo "=== STEP 2: Verify files on server ==="
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling
echo "Current directory: $(pwd)"
echo ""
echo "Checking critical files:"
ls -lh src/components/ui/SystemInterface.jsx && echo "✓ SystemInterface.jsx" || echo "✗ MISSING SystemInterface.jsx"
ls -lh src/components/ui/GlobalInterface.astro && echo "✓ GlobalInterface.astro" || echo "✗ MISSING GlobalInterface.astro"  
ls -lh src/components/ui/CyberConsole.css && echo "✓ CyberConsole.css" || echo "✗ MISSING CyberConsole.css"
ls -lh src/pages/index.astro && echo "✓ index.astro" || echo "✗ MISSING index.astro"

echo ""
echo "Checking if GlobalInterface is imported in index.astro:"
grep -n "GlobalInterface" src/pages/index.astro || echo "✗ GlobalInterface NOT imported"

echo ""
echo "Checking package.json for dependencies:"
grep -A 3 "framer-motion\|lucide-react" package.json || echo "✗ Missing dependencies"
EOF

echo ""
echo "=== STEP 3: Clean old build and rebuild ==="
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling
echo "Removing old dist folder..."
rm -rf dist
echo "Running build..."
npm run build
echo ""
echo "Build exit code: $?"
echo ""  
echo "Checking if build created files:"
ls -lh dist/ | head -10
EOF

echo ""
echo "=== STEP 4: Check if SystemInterface is in built files ==="
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 << 'EOF'
cd ~/sites/jumpstartscaling
echo "Searching for SystemInterface in built JS files:"
find dist -name "*.js" -exec grep -l "SystemInterface\|system-interface" {} \; | head -5
echo ""
echo "Searching for quick-nav-react class:"
find dist -name "*.js" -exec grep -l "quick-nav-react" {} \; | head -5
EOF

echo ""  
echo "=== STEP 5: Restart PM2 ==="
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 "pm2 restart jumpstartscaling && pm2 list"

echo ""
echo "=== STEP 6: Purge Cloudflare ==="
curl -X POST "https://api.cloudflare.com/client/v4/zones/f1e606b93260b3e12a939612c12c6370/purge_cache" \
  -H "Authorization: Bearer nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}' \
  -w "\nHTTP Status: %{http_code}\n"

echo ""
echo "=== DEPLOYMENT COMPLETE ==="
date
