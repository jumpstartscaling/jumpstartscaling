# 🚀 Production Deployment Guide

## Pre-Deployment Checklist

### 1. **Run All Tests**
```bash
# Type checking
npm run typecheck

# Unit tests
npm test

# E2E tests
npx playwright install
npm run test:e2e

# Build test
npm run build
```

### 2. **Performance Audit**
```bash
# Start preview server
npm run preview

# Run Lighthouse
lighthouse http://localhost:4321 --view

# Target scores:
# - Performance: 90+
# - Accessibility: 95+
# - Best Practices: 95+
# - SEO: 100
```

### 3 **Security Audit**
```bash
# Check for vulnerabilities
npm audit

# Fix auto-fixable issues
npm audit fix

# Review manual fixes
npm audit --production
```

---

## Production Build Configuration

### **Switch to Production Config**

```bash
# Backup current config
cp astro.config.mjs astro.config.dev.mjs

# Use production config
cp astro.config.production.mjs astro.config.mjs
```

### **Production Environment Variables**

Create `.env.production`:

```bash
# Core
NODE_ENV=production
SITE_URL=https://spark.jumpstartscaling.com

# Database (Production PostgreSQL via Docker network)
DATABASE_URL=postgres://spark-god-mode:PASSWORD@ykgkos00co4k48480ccs8sow:5432/arc-net

# Redis
REDIS_URL=redis://redis:6379
REDIS_HOST=redis
REDIS_PORT=6379

# API Keys
GOD_MODE_TOKEN=your_production_token_here

# Directus
DIRECTUS_URL=https://office.jumpstartscaling.com
PUBLIC_DIRECTUS_URL=https://office.jumpstartscaling.com

# Sentry (Error Tracking)
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
SENTRY_ENVIRONMENT=production

# Feature Flags
ENABLE_PWA=true
ENABLE_COMPRESSION=true
ENABLE_ANALYTICS=true
```

---

## Deployment Steps

### **Option 1: Coolify Deployment (Recommended)**

1. **Push to Git:**
```bash
git add .
git commit -m "chore: production-ready build"
git push origin main
```

2. **Coolify will automatically:**
   - Pull latest code
   - Run `npm install`
   - Execute `npm run build`
   - Start with `node ./dist/server/entry.mjs`

3. **Verify deployment:**
   - Visit https://spark.jumpstartscaling.com
   - Check all services are online
   - Test critical user flows

### **Option 2: Manual Docker Build**

```bash
# Build Docker image
docker build -t god-mode:latest .

# Run container
docker run -d \
  --name god-mode \
  --env-file .env.production \
  -p 4321:4321 \
  god-mode:latest
```

###  **Option 3: Direct Node Deployment**

```bash
# Build for production
NODE_ENV=production npm run build

# Start production server
NODE_ENV=production node ./dist/server/entry.mjs
```

---

## Post-Deployment Verification

### **1. Service Health Checks**

```bash
# System health
curl https://spark.jumpstartscaling.com/api/system/health

# Database connection
curl -H "X-God-Token: TOKEN" \
  https://spark.jumpstartscaling.com/api/god/pool/stats

# Python Bridge
curl https://spark.jumpstartscaling.com/api/python/api/status
```

### **2. Verify Static Assets**

- Sitemap: https://spark.jumpstartscaling.com/sitemap-index.xml
- Robots: https://spark.jumpstartscaling.com/robots.txt
- PWA Manifest: https://spark.jumpstartscaling.com/manifest.json
- Service Worker: Check in DevTools > Application

### **3. Performance Monitoring**

```bash
# Check Web Vitals
# Visit: https://spark.jumpstartscaling.com/admin/analytics/performance

# Monitor Sentry
# Visit: https://sentry.io/organizations/your-org/projects/god-mode/
```

### **4. Functional Tests**

Test these critical flows:
- [ ] Can access `/admin` dashboard
- [ ] Can run SQL queries from terminal
- [ ] Can generate content from factory
- [ ] All API endpoints return 200
- [ ] PWA is installable
- [ ] Service worker is active

---

## Rollback Plan

If issues occur:

### **Quick Rollback**

```bash
# Revert to previous config
git revert HEAD
git push origin main

# Or use previous commit
git reset --hard <previous-commit-hash>
git push origin main --force
```

### **Emergency Rollback**

```bash
# Switch back to dev config
cp astro.config.dev.mjs astro.config.mjs

# Rebuild
npm run build

# Restart services
systemctl restart god-mode
```

---

## Monitoring & Maintenance

###  **Key Metrics to Monitor**

1. **Performance**
   - Response time < 200ms (avg)
   - Build time < 40s
   - Bundle size < 850KB

2. **Errors**
   - Error rate < 0.1%
   - No 500/504 errors
   - Sentry alerts < 5/day

3. **Resources**
   - CPU usage < 50%
   - Memory < 8GB
   - Database connections < 20

### **Daily Checks**

```bash
# Check logs
docker logs god-mode --tail=100

# Check database
docker exec god-mode node -e "
  const { Pool } = require('pg');
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  pool.query('SELECT NOW()').then(r => console.log('DB OK:', r.rows[0]));
"

# Check Redis
docker exec god-mode node -e "
  const Redis = require('ioredis');
  const redis = new Redis(process.env.REDIS_URL);
  redis.ping((err, result) => console.log('Redis:', result));
"
```

### **Weekly Maintenance**

```bash
# Update dependencies
npm update

# Run security audit
npm audit

# Clear old caches
npm cache clean --force

# Database vacuum (if needed)
curl -X POST -H "X-God-Token: TOKEN" \
  https://spark.jumpstartscaling.com/api/god/mechanic/execute?action=vacuum
```

---

## Optimization Tips

### **After First Week**

1. **Analyze Bundle:**
```bash
npm run analyze
# Review bundle report
# Identify large dependencies
# Consider lazy loading heavy components
```

2. **Check Coverage:**
```bash
npm run test:coverage
# Aim for 80%+ coverage
# Add tests for critical paths
```

3. **Review Lighthouse:**
```bash
lighthouse https://spark.jumpstartscaling.com --view
# Address any warnings
# Optimize images if needed
```

### **Monthly Optimizations**

- Review and update dependencies
- Analyze Sentry error patterns
- Optimize slow database queries
- Review and archive old content
- Update security headers

---

## Troubleshooting

### **Build Fails**

```bash
# Clear all caches
rm -rf node_modules dist .astro
npm install
npm run build
```

### **Performance Degradation**

```bash
# Check bundle size
npm run analyze

# Profile build
NODE_OPTIONS="--max-old-space-size=8192" npm run build -- --verbose

# Clear Redis
redis-cli FLUSHALL
```

### **High Memory Usage**

```bash
# Increase Node memory
export NODE_OPTIONS="--max-old-space-size=16384"

# Restart services
pm2 restart god-mode
```

---

## Success Criteria

After deployment, verify:

- ✅ All services show "Operational" in Awaken dashboard
- ✅ Lighthouse score 90+ on all metrics
- ✅ No JavaScript errors in console
- ✅ PWA installable
- ✅ All API endpoints functional
- ✅ Database connections stable
- ✅ Redis queue processing
- ✅ Error rate < 0.1%

---

**Deployment Checklist Complete? Deploy with confidence! 🚀**
