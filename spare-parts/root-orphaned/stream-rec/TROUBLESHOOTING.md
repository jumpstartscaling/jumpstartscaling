# Stream-Rec Troubleshooting

## Current Status

The Stream-Rec containers are running, but there's an authentication/redirect issue with the frontend.

## What's Working

✅ Docker containers are running  
✅ Nginx is configured and running  
✅ SSL certificate is installed  
✅ Backend API is accessible (port 12555)  
✅ Frontend is running (port 15275)  

## The Issue

The Next.js frontend has authentication that's causing redirect loops and "header overflow" errors. This is a known issue with next-auth and large cookies.

## Quick Fixes to Try

### Option 1: Access via Direct IP (Bypass Domain)

Try accessing directly:
```
http://193.122.168.215:15275/
```

This bypasses Nginx and domain-based auth issues.

### Option 2: Clear Browser Cache & Cookies

1. Clear all cookies for `rec.jumpstartscaling.com`
2. Clear browser cache
3. Try accessing in incognito/private mode
4. Try: https://rec.jumpstartscaling.com/

### Option 3: Use Backend API Directly

The backend API is working. You can use Stream-Rec via API calls:

**Backend URL:** http://193.122.168.215:12555/api

**Default login:**
- Username: `stream-rec`
- Password: `stream-rec`

### Option 4: Restart with Fresh Session

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215
cd /home/opc/stream-rec

# Clear any cached session data
rm -rf downloads/.session* 2>/dev/null

# Restart containers
docker compose restart

# Check logs
docker compose logs -f
```

## Root Cause

The issue is with Next.js Auth (next-auth) creating large session cookies that exceed buffer limits. The official Stream-Rec docker image may need updates to handle this properly.

## Recommended Next Steps

1. **Report to Stream-Rec project:** This appears to be a bug in their Docker deployment
2. **Use alternative access:** Direct IP or API access
3. **Monitor updates:** Check https://github.com/stream-rec/stream-rec for fixes

## Current Configuration

- **Server IP:** 193.122.168.215
- **Domain:** rec.jumpstartscaling.com
- **Frontend Port:** 15275 (internal)
- **Backend Port:** 12555 (internal)
- **Nginx Ports:** 80 (HTTP), 443 (HTTPS)

---

Let me know which option you'd like to pursue!
