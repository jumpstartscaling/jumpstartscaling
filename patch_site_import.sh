#!/bin/bash
set -e

# Go to dir
cd /home/opc/sites/jumpstartscaling

# 1. Inject Import
# Insert import at line 4
sed -i '4i import "../styles/features.css";' src/pages/index.astro

# 2. Replace Services HTML
START=$(grep -n "<!-- Services -->" src/pages/index.astro | cut -d: -f1)
END=$(grep -n "<!-- Survey Section -->" src/pages/index.astro | cut -d: -f1)

if [ -z "$START" ] || [ -z "$END" ]; then
  echo "Could not find start/end markers"
  exit 1
fi

echo "Replacing HTML from line $START to $END..."
DEL_END=$((END - 1))
sed -i "${START},${DEL_END}d" src/pages/index.astro

INSERT_POINT=$((START - 1))
sed -i "${INSERT_POINT}r partial_services.html" src/pages/index.astro

echo "Patch complete. Building..."
npm run build
