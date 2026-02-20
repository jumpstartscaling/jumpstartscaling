#!/bin/sh
# Start chrisamaya Astro server (SSR) on 8101, then router on 8100.
# chrisamaya.work and /chrisamaya requests are proxied by router to the Astro server.
# Set PUBLIC_GOD_MODE_API_URL (or GOD_MODE_API_URL) so SSR can fetch tenant API.
set -e
CHRIS_PORT="${CHRISAMAYA_PORT:-8101}"
export HOST="${CHRISAMAYA_HOST:-0.0.0.0}"
# Fallback: use GOD_MODE_API_URL if PUBLIC_GOD_MODE_API_URL not set (build-time may have embedded it)
export PUBLIC_GOD_MODE_API_URL="${PUBLIC_GOD_MODE_API_URL:-$GOD_MODE_API_URL}"

cd /app/sites/chrisamaya
PORT="$CHRIS_PORT" node dist/server/entry.mjs &
cd /app
# Allow chrisamaya server to bind before router starts
sleep 2
# Router must listen on 8100 (healthcheck expects it)
export PORT="${PORT:-8100}"
exec node router.js
