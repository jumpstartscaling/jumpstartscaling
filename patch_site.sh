#!/bin/bash
set -e

# Go to dir
cd /home/opc/sites/jumpstartscaling

# 1. Inject Styles
# Add a marker before </style>
sed -i '/<\/style>/i STYLE_MARKER' src/pages/index.astro
# Read file after marker (which places it after the marker, i.e., before </style> effectively if we delete marker)
# Wait, 'r' appends AFTER the line matching.
# If I have:
# STYLE_MARKER
# </style>
# And I match STYLE_MARKER and read file, it goes:
# STYLE_MARKER
# <file content>
# </style>
# Perfect.
sed -i '/STYLE_MARKER/r partial_styles.css' src/pages/index.astro
# Remove marker
sed -i '/STYLE_MARKER/d' src/pages/index.astro

# 2. Replace Services HTML
# Find lines
START=$(grep -n "<!-- Services -->" src/pages/index.astro | cut -d: -f1)
END=$(grep -n "<!-- Survey Section -->" src/pages/index.astro | cut -d: -f1)

if [ -z "$START" ] || [ -z "$END" ]; then
  echo "Could not find start/end markers"
  exit 1
fi

echo "Replacing HTML from line $START to $END..."

# We want to replace everything from <!-- Services --> up to BUT NOT INCLUDING <!-- Survey Section -->
# So we delete from START to END-1.
DEL_END=$((END - 1))
sed -i "${START},${DEL_END}d" src/pages/index.astro

# Now insert new content. We need to insert it where START was.
# Since we deleted lines, the previous line is START-1.
INSERT_POINT=$((START - 1))
sed -i "${INSERT_POINT}r partial_services.html" src/pages/index.astro

echo "Patch complete. Building..."
npm run build
