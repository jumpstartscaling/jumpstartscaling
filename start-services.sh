#!/bin/bash
# God Mode Dual-Service Startup Script
# Runs both the Astro SSR server and the Python FastAPI bridge

set -e

echo "🔱 God Mode - Starting Dual Services..."

# Start Python Bridge in background
echo "📡 Starting Python Bridge (FastAPI) on port 8505..."
python3 god_architect_local/forever_connection.py &
BRIDGE_PID=$!

# Give bridge a moment to start
sleep 2

# Check if bridge started successfully
if kill -0 $BRIDGE_PID 2>/dev/null; then
    echo "✅ Python Bridge started (PID: $BRIDGE_PID)"
else
    echo "⚠️  Python Bridge failed to start, continuing anyway..."
fi

# Start Astro SSR server (foreground)
echo "🚀 Starting Astro SSR Server on port 4321..."
exec node ./dist/server/entry.mjs
