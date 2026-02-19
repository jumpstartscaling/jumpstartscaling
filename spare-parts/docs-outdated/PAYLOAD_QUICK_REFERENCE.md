# ⚡ Payload CMS Quick Reference

## 📍 Project Location
```
Server: opc@193.122.168.215
Path: /home/opc/payload-multitenant
```

## 🚀 Quick Deploy Checklist

### 1. Create GitHub Repo
- Visit: https://github.com/new
- Name: `jumpstart-cms`
- Private repo
- Don't initialize with README

### 2. Push Code
```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215
cd /home/opc/payload-multitenant
git config user.name "Your Name"
git config user.email "your@email.com"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/jumpstart-cms.git
git push -u origin main
```

### 3. Setup in Coolify (http://193.122.168.215:8000)

**Create PostgreSQL Database:**
- Name: `jumpstart-cms-db`
- Version: 16
- Database: `payload`
- User: `payload_user`
- Copy connection string!

**Create Project:**
- Name: `JumpStart CMS`

**Add Application:**
- Repo: `https://github.com/YOUR_USERNAME/jumpstart-cms`
- Branch: `main`
- Port: `3000`

**Environment Variables:**
```bash
DATABASE_URI=postgres://payload_user:PASSWORD@jumpstart-cms-db:5432/payload
PAYLOAD_SECRET=$(openssl rand -base64 32)
PAYLOAD_CONFIG_PATH=src/payload.config.ts
NEXT_PUBLIC_SERVER_URL=https://cms.jumpstartscaling.com
PORT=3000
NODE_ENV=production
```

**Domain:**
- `cms.jumpstartscaling.com`
- SSL: Enabled

### 4. DNS Configuration
```
Type: A
Name: cms
Content: 193.122.168.215
Proxy: ON (Cloudflare)
```

### 5. Deploy
- Click **"Deploy"** in Coolify
- Wait for success message
- Visit: https://cms.jumpstartscaling.com

---

## 🎯 First Steps After Deployment

1. **Create Admin User** at `/admin`
2. **Create First Tenant:**
   - Name: `JumpStart Scaling Hub`
   - Slug: `hub`
   - Domain: `jumpstartscaling.com`
3. **Create First Page:**
   - Title: `Home`
   - Tenant: Hub
   - Status: Published

---

## 🔗 URLs

- **Admin Panel**: https://cms.jumpstartscaling.com/admin
- **API**: https://cms.jumpstartscaling.com/api
- **GraphQL**: https://cms.jumpstartscaling.com/api/graphql
- **Coolify**: http://193.122.168.215:8000

---

## 📦 Collections

| Collection | Purpose | Key Fields |
|------------|---------|-----------|
| Users | Authentication | email, password, roles, tenant |
| Tenants | Multi-tenancy | name, slug, domain |
| Pages | Content | title, slug, tenant, content |
| Media | File uploads | file, alt, tenant |

---

## 🛠️ Useful Commands

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Navigate to project
cd /home/opc/payload-multitenant

# Check git status
git status

# Push  updates
git add .
git commit -m "Update"
git push

# Generate secret
openssl rand -base64 32
```

---

## ❓ Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't access admin | Check DNS, wait for SSL, clear cache |
| Build fails | Check env vars, review Coolify logs |
| DB connection error | Verify DATABASE_URI, check PostgreSQL status |
| 502 error | App may still be starting, wait 30s |

---

## 📞 Status Check

Current project status on server:
```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 "cd /home/opc/payload-multitenant && ls -la && git status"
```

---

**Full Guide:** See `PAYLOAD_CMS_DEPLOYMENT_GUIDE.md`
