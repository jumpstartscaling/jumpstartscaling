# 🔱 God Mode - Local Database Connection Setup

## 🎯 Problem Solved

**Issue**: Local development can't connect to the database because `DATABASE_URL` uses the Coolify internal hostname (`ykgkos00co4k48480ccs8sow`) which only works inside the Docker network.

**Solution**: Use SSH tunnel to connect to the production database from your local Mac.

---

## 🚀 Quick Fix (Option 1: SSH Tunnel - Recommended)

### Step 1: Create SSH Tunnel

```bash
# Open tunnel to production database
# Replace YOUR_SERVER with your Coolify server hostname/IP
ssh -L 5433:ykgkos00co4k48480ccs8sow:5432 root@YOUR_COOLIFY_SERVER -N

# Leave this running in a terminal tab
```

### Step 2: Update Local .env

```bash
# Edit .env
DATABASE_URL="postgres://spark-god-mode:eEQme6YUWIMYP20bUjf6ZE75BX1HrVMXv9Z5TBsWr8NP94JxjsdnW0NB8vvczHlC@localhost:5433/arc-net"
```

### Step 3: Restart Dev Server

```bash
# Kill the current dev server (Ctrl+C)
npm run dev
```

✅ **Done!** Your local God Mode can now access the database through the tunnel.

---

## 🔐 Alternative: Direct Connection (Option 2)

If the database has a public port exposed in Coolify:

###Check if Port is Exposed

1. Log into Coolify dashboard
2. Navigate to PostgreSQL service
3. Check "Ports" tab
4. Look for public port mapping (e.g., `5432:54321`)

### Update .env

```bash
# Use the public port
DATABASE_URL="postgres://spark-god-mode:eEQme6YUWIMYP20bUjf6ZE75BX1HrVMXv9Z5TBsWr8NP94JxjsdnW0NB8vvczHlC@YOUR_SERVER_IP:54321/arc-net?sslmode=require"
```

---

## 🐳 Production (Coolify) - No Changes Needed!

**Production already works** because:
- God Mode container is on the `coolify` network (docker-compose.yml line 34)
- Database hostname `ykgkos00co4k48480ccs8sow` resolves within that network
- Current `DATABASE_URL` in Coolify is correct ✅

**Do NOT change the DATABASE_URL in Coolify production environment!**

---

## 🧪 Test Connection

After setting up the tunnel or direct connection:

```bash
# Test with Node
node --input-type=module -e "import pg from 'pg'; const pool = new pg.Pool({connectionString: process.env.DATABASE_URL}); pool.query('SELECT NOW() as time, current_database() as db').then(r => {console.log('✅ Connected:', r.rows[0]); process.exit(0)}).catch(e => {console.error('❌ Error:', e.message); process.exit(1)})"
```

Expected output:
```
✅ Connected: { time: 2025-12-20T..., db: 'arc-net' }
```

---

## 📋 Troubleshooting

### "Connection refused" on localhost:5433
- **Cause**: SSH tunnel not running
- **Fix**: Start the SSH tunnel in a separate terminal

### "ECONNREFUSED ykgkos00co4k48480ccs8sow:5432"
- **Cause**: Trying to use production hostname locally
- **Fix**: Update`.env` to use `localhost:5433` (tunnel) or public IP

### "password authentication failed"
- **Cause**: Wrong password in DATABASE_URL
- **Fix**: Get correct password from Coolify environment variables

### SSH tunnel closes immediately
- **Cause**: SSH key/auth issue
- **Fix**: Test SSH first: `ssh root@YOUR_SERVER` to verify access

---

## 🔄 Automated Tunnel Script

Create `scripts/db-tunnel.sh`:

```bash
#!/bin/bash
# God Mode - Database Tunnel
# Usage: ./scripts/db-tunnel.sh

SERVER="YOUR_COOLIFY_SERVER"  # Replace with actual server
LOCAL_PORT=5433
REMOTE_HOST="ykgkos00co4k48480ccs8sow"
REMOTE_PORT=5432

echo "🔱 Starting God Mode Database Tunnel..."
echo "📡 Connecting to: $SERVER"
echo "🔗 Local port: $LOCAL_PORT → Remote: $REMOTE_HOST:$REMOTE_PORT"
echo ""
echo "✅ Tunnel ready! Press Ctrl+C to close."
echo "📝 Use in .env: DATABASE_URL=\"postgres://...@localhost:$LOCAL_PORT/arc-net\""
echo ""

ssh -L $LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT root@$SERVER -N
```

Make executable:
```bash
chmod +x scripts/db-tunnel.sh
```

Run:
```bash
./scripts/db-tunnel.sh
```

---

## ✅ Summary

| Environment | DATABASE_URL | Works? |
|-------------|--------------|--------|
| **Production (Coolify)** | `postgres://...@ykgkos00co4k48480ccs8sow:5432/arc-net` | ✅ (in Docker network) |
| **Local (Mac)** | `postgres://...@localhost:5433/arc-net` | ✅ (via SSH tunnel) |

**Next Steps:**
1. Set up the SSH tunnel
2. Update local `.env`  
3. Restart `npm run dev`
4. All API endpoints should work! 🎉
