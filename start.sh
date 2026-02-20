#!/bin/sh
# Start chrisamaya SSR on 8101, then router on 8100
set -e

# API base for chrisamaya blog fetch (middleware reads process.env)
export PUBLIC_API_URL="${PUBLIC_GOD_MODE_API_URL:-${GOD_MODE_API_URL:-https://api.jumpstartscaling.com}}"

# Start chrisamaya SSR in background
cd /app/sites/chrisamaya
HOST=0.0.0.0 PORT=8101 node ./dist/server/entry.mjs &
SSR_PID=$!
cd /app

# Give SSR a moment to bind
sleep 2

# Start router (foreground - keeps container alive)
exec node router.js
