# ✅ ENVIRONMENT VARIABLES FOR COOLIFY

Copy and paste these **exact values** into your Coolify application's Environment Variables section:

---

## DATABASE_URI
```
postgres://postgres:2KBvlXHRLX1H0xjKxwSBuJKi4ndwALBTvfRtthsjGpuZd0X5nIKm2TUP0R1ykJ7G@ok4gk4kc4kk0w4wgsksskswg:5432/postgres
```

## PAYLOAD_SECRET
```
9H4c3FiY2BNsrL1sLpylkH+wejnKwYrhdKLsrxChUpk=
```

## PAYLOAD_CONFIG_PATH
```
src/payload.config.ts
```

## NEXT_PUBLIC_SERVER_URL
```
https://cms.jumpstartscaling.com
```

## PORT
```
3000
```

## NODE_ENV
```
production
```

---

## 📋 Quick Copy-Paste List

For Coolify UI, add these as individual environment variables:

| Key | Value |
|-----|-------|
| `DATABASE_URI` | `postgres://postgres:2KBvlXHRLX1H0xjKxwSBuJKi4ndwALBTvfRtthsjGpuZd0X5nIKm2TUP0R1ykJ7G@ok4gk4kc4kk0w4wgsksskswg:5432/postgres` |
| `PAYLOAD_SECRET` | `9H4c3FiY2BNsrL1sLpylkH+wejnKwYrhdKLsrxChUpk=` |
| `PAYLOAD_CONFIG_PATH` | `src/payload.config.ts` |
| `NEXT_PUBLIC_SERVER_URL` | `https://cms.jumpstartscaling.com` |
| `PORT` | `3000` |
| `NODE_ENV` | `production` |

---

## 🚀 Next Steps

1. ✅ PostgreSQL Database Created
2. ⏳ **NOW**: Add these 6 environment variables in Coolify
3. ⏳ Set domain: `cms.jumpstartscaling.com` (with SSL enabled)
4. ⏳ Click "Deploy"
5. ⏳ Add DNS record (while building)
6. ✅ Access your CMS!

---

## 🌐 DNS Configuration (Do While Building)

Add to Cloudflare DNS:

```
Type: A
Name: cms
Content: 193.122.168.215
Proxy: ON (Orange Cloud)
```

---

## ✅ After Deployment

Visit: `https://cms.jumpstartscaling.com`

You should see:
```
🚀 JumpStart Scaling CMS
Multi-tenant content management system.
```

Click "Go to Admin Dashboard" to create your first admin user!

---

**Status**: Database ✅ | Environment Variables ✅ Ready to Paste | Deploy ⏳
