# Multi-Site Astro Setup

Zero-latency multi-domain routing for Astro static sites.

## Sites

- **JumpStart Scaling**: `jumpstartscaling.com`
- **Chris Amaya**: `chrisamaya.work`

## Architecture

### Local Setup
Each site is in `sites/[sitename]/`:
- Independent Astro projects
- Own package.json and dependencies
- Static builds to `dist/`

### Router (`router.js`)
- Lightweight Node.js HTTP server
- Domain-based routing (zero latency)
- Serves correct site based on `Host` header
- No database, no CMS overhead

## Development

```bash
# Work on a specific site
cd sites/jumpstartscaling
npm run dev

cd sites/chrisamaya
npm run dev
```

## Deployment

```bash
# Build and deploy both sites
./deploy.sh
```

This will:
1. Build both Astro sites
2. Upload to server (`193.122.168.215`)
3. Restart the router via PM2

## Server Setup

The router runs on port 8100 and Nginx proxies domains:

```nginx
server {
    server_name jumpstartscaling.com www.jumpstartscaling.com;
    location / {
        proxy_pass http://localhost:8100;
        proxy_set_header Host $host;
    }
}

server {
    server_name chrisamaya.work www.chrisamaya.work;
    location / {
        proxy_pass http://localhost:8100;
        proxy_set_header Host $host;
    }
}
```

## Adding New Sites

1. Create new Astro project in `sites/newsitename/`
2. Add mapping to `router.js` `DOMAIN_MAP`
3. Update `deploy.sh` to include new site
4. Add Nginx config on server

## Why This Works

- **Fast**: Static files served directly from memory-mapped filesystem
- **Simple**: No CMS, no database, no authentication
- **Reliable**: Each site is independent, failures don't cascade
- **Scalable**: Add unlimited domains without performance impact
