# 🎉 Payload Multi-Tenant CMS - Setup Complete!

## ✅ What Was Done

### 1. Cleaned Up Coolify
- ✅ Deleted 5 old/failed applications from Coolify database
- ✅ Removed old containers
- ✅ Fresh start for new deployment

### 2. Created Payload CMS Project
- ✅ Location on server: `/home/opc/payload-multitenant`
- ✅ Framework: Next.js 15 + Payload CMS 3.9.1
- ✅ Database: PostgreSQL adapter configured
- ✅ Collections ready: Users, Tenants, Pages, Media
- ✅ Git repository initialized
- ✅ All dependencies installed

### 3. Project Structure
```
payload-multitenant/
├── src/
│   ├── app/
│   │   ├── (payload)/admin/     # Admin dashboard
│   │   ├── layout.tsx
│   │   ├── page.tsx             # Home page
│   │   └── globals.css
│   ├── collections/
│   │   ├── Users.ts             # User authentication
│   │   ├── Tenants.ts           # Multi-tenant management
│   │   ├── Pages.ts             # Content pages
│   │   └── Media.ts             # Media library
│   ├── payload.config.ts        # Payload configuration
│   └── payload-config.ts
├── public/
├── package.json
├── tsconfig.json
├── next.config.ts
├── .env.example
├── README.md
└── DEPLOYMENT_GUIDE.md
```

---

## 🚀 Next Steps to Deploy

### Step 1: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: **`jumpstart-cms`** (or your preferred name)
3. Description: `Multi-tenant CMS for JumpStart Scaling`
4. Privacy: **Private** (recommended)
5. **DO NOT** initialize with README, .gitignore, or license
6. Click **"Create repository"**
7. Copy the repository URL

### Step 2: Push Code to GitHub

Run these commands:

```bash
# SSH into your server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Navigate to project
cd /home/opc/payload-multitenant

# Configure git (first time only)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Rename branch to main
git branch -M main

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/jumpstart-cms.git

# Push to GitHub
git push -u origin main
```

**Important:** Replace `YOUR_USERNAME` with your actual GitHub username!

### Step 3: Set Up PostgreSQL in Coolify

1. Open Coolify dashboard: **http://193.122.168.215:8000**
2. Click **"+ New Resource"** → **"PostgreSQL"**
3. Configure:
   - **Name**: `jumpstart-cms-db`
   - **Postgres Version**: `16` (latest)
   - **Database Name**: `payload`
   - **Username**: `payload_user`
   - **Password**: (will be auto-generated - **COPY THIS!**)
4. Click **"Create"**
5. Wait for database to start (green status)
6. Click on the database resource
7. **Copy the Internal Connection URL**. It will look like:
   ```
   postgres://payload_user:GENERATED_PASSWORD@jumpstart-cms-db:5432/payload
   ```

### Step 4: Create New Project in Coolify

1. In Coolify, go to **"Projects"**
2. Click **"+ New Project"**
3. Name: `JumpStart CMS`
4. Description: `Multi-tenant content management system`
5. Click **"Create"**

### Step 5: Deploy Application

1. Inside your new project, click **"+ New Resource"** → **"Application"**
2. Choose **"Public Repository"** (or connect GitHub if you have GitHub app installed)
3. Enter your repository URL: `https://github.com/YOUR_USERNAME/jumpstart-cms`
4. Click **"Continue"**

#### Build Settings:
- **Branch**: `main`
- **Build Pack**: Nixpacks (auto-detected for Next.js)
- **Build Command**: Leave default or set to `npm run build`
- **Start Command**: `npm run start`
- **Port**: `3000`

#### Environment Variables:
Click **"Environment Variables"** and add these:

```bash
DATABASE_URI=postgres://payload_user:YOUR_PASSWORD@jumpstart-cms-db:5432/payload
PAYLOAD_SECRET=YOUR_GENERATED_SECRET
PAYLOAD_CONFIG_PATH=src/payload.config.ts
NEXT_PUBLIC_SERVER_URL=https://cms.jumpstartscaling.com
PORT=3000
NODE_ENV=production
```

**To generate PAYLOAD_SECRET**, run on your local machine:
```bash
openssl rand -base64 32
```

#### Domain Configuration:
1. Go to **"Domains"** tab
2. Add domain: `cms.jumpstartscaling.com`
3. Enable **SSL/TLS** (Let's Encrypt will be automatically configured)
4. Click **"Save"**

#### Deploy:
1. Click **"Deploy"** button
2. Monitor build logs
3. Wait for "✅ Deployed successfully"

### Step 6: Configure DNS

Add this A record in your DNS provider (likely Cloudflare):

| Type | Name | Content | Proxy | TTL |
|------|------|---------|-------|-----|
| A | `cms` | `193.122.168.215` |  ☁️ Proxied | Auto |

**Wait 1-5 minutes for DNS propagation**

### Step 7: Access Your CMS

1. Visit: **https://cms.jumpstartscaling.com**
2. You should see: "🚀 JumpStart Scaling CMS"
3. Click **"Go to Admin Dashboard"**
4. Create your first admin user:
   - **Email**: your@email.com
   - **Password**: (strong password)
   - **Name**: Admin
   - **Roles**: Select `admin`
5. Click **"Create"**

---

## 📊 Collections Explained

### 🏢 Tenants
Multi-tenant management. Each tenant represents a separate site/client.

**Fields:**
- Name: Display name of the tenant
- Slug: URL-friendly identifier
- Domain: Primary domain (e.g., `jumpstartscaling.com`)
- Additional Domains: Array of alternate domains
- Logo: Upload tenant logo
- Primary Color: Brand color
- Active: Enable/disable tenant

**Example Tenant:**
- Name: `JumpStart Scaling Hub`
- Slug: `hub`
- Domain: `jumpstartscaling.com`
- Active: ✅

### 📄 Pages
Content pages scoped to tenants.

**Fields:**
- Title: Page title
- Slug: URL slug
- Tenant: Which tenant owns this page
- Content: Rich text editor
- Status: Draft or Published
- Published At: Publication date

**Example Page:**
- Title: `Home`
- Slug: `home`
- Tenant: JumpStart Scaling Hub
- Status: Published

### 👥 Users
Admin and editor accounts.

**Fields:**
- Email: Login email
- Password: Hashed password
- Name: Display name
- Roles: admin, editor, viewer
- Tenant: Optional tenant assignment

**Roles:**
- `admin`: Full access
- `editor`: Can edit content
- `viewer`: Read-only

### 🖼️ Media
Image and file uploads.

**Fields:**
- File: Upload
- Alt Text: Accessibility description
- Tenant: Optional tenant assignment

**Auto-generated sizes:**
- Thumbnail: 400x300
- Card: 768x1024
- Tablet: 1024px width

---

## 🔌 API Reference

Your Payload CMS exposes a powerful REST and GraphQL API.

### REST API Base URL:
```
https://cms.jumpstartscaling.com/api
```

### Authentication:
```bash
# Login POST /api/users/login
curl -X POST https://cms.jumpstartscaling.com/api/users/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"yourpassword"}'

# Returns: { "user": {...}, "token": "JWT_TOKEN" }
```

### Endpoints:

#### Tenants:
- `GET /api/tenants` - List all tenants
- `GET /api/tenants/:id` - Get specific tenant
- `POST /api/tenants` - Create tenant (auth required)
- `PATCH /api/tenants/:id` - Update tenant (auth required)
- `DELETE /api/tenants/:id` - Delete tenant (auth required)

#### Pages:
- `GET /api/pages` - List pages
- `GET /api/pages/:id` - Get specific page
- `GET /api/pages?where[tenant][equals]=TENANT_ID` - Filter by tenant
- `GET /api/pages?where[status][equals]=published` - Only published

#### Media:
- `GET /api/media` - List media files
- `POST /api/media` - Upload media (multipart/form-data)

### GraphQL:
```
https://cms.jumpstartscaling.com/api/graphql
```

**Example Query:**
```graphql
query {
  Pages(where: { status: { equals: published } }) {
    docs {
      id
      title
      slug
      tenant {
        name
        domain
      }
      content
    }
  }
}
```

---

## 🎨 Customization Ideas

### 1. Add More Collections
Create custom collections for your needs:
- Blog Posts
- Products
- Team Members
- Testimonials
- Case Studies

### 2. Custom Hooks
Add business logic with Payload hooks:
- Auto-publish on certain conditions
- Send notifications
- Validate data
- Transform content

### 3. Custom Fields
Extend collections with:
- SEO metadata
- Custom layouts
- Feature flags
- Analytics tracking

### 4. Frontend Integration
Use the API in your frontend:
- Next.js site generator
- React app with SWR
- Static site generation
- Incremental Static Regeneration

---

## 🔒 Security Best Practices

- ✅ Use strong `PAYLOAD_SECRET` (32+ characters)
- ✅ Enable Cloudflare proxy for DDoS protection
- ✅ Use strong admin passwords
- ✅ Regularly update dependencies
- ✅ Enable 2FA on GitHub account
- ✅ Restrict API access with JWT tokens
- ✅ Regular database backups

---

## 🐛 Troubleshooting

### Application Won't Start
**Check:**
1. Environment variables are set correctly
2. `DATABASE_URI` is correct
3. PostgreSQL database is running
4. Build logs in Coolify for errors

### Can't Access Admin
**Try:**
1. Check domain points to `193.122.168.215`
2. Wait for SSL certificate (can take 2-5 minutes)
3. Clear browser cache
4. Try incognito mode
5. Check Coolify logs

### Database Connection Errors
**Verify:**
1. PostgreSQL container is running (green in Coolify)
2. Connection string format is exact
3. No extra spaces in environment variables
4. Database name is `payload`

### Build Fails
**Common issues:**
1. Missing environment variables
2. Node version mismatch (need 18+ or 20+)
3. NPM install failed - check logs
4. TypeScript errors - review code

---

## 📈 Monitoring & Maintenance

### View Logs:
1. Go to Coolify dashboard
2. Click on your application
3. **"Logs"** tab → Real-time logs

### Database Backups:
Coolify automatically backs up PostgreSQL databases daily.

### Manual Backup:
```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215
docker exec jumpstart-cms-db pg_dump -U payload_user payload > backup-$(date +%Y%m%d).sql
```

### Redeploy:
1. Make changes locally
2. Commit and push to GitHub
3. In Coolify, click **"Redeploy"** or wait for auto-deploy

---

##✨ What Makes This Multi-Tenant?

### Tenant Isolation:
- Each tenant has unique domain(s)
- Pages are scoped to tenants
- Media can be tenant-specific
- Users can be assigned to tenants

### How to Add a New Tenant:

1. Create tenant in admin:
   - Name: `My New Site`
   - Slug: `newsite`
   - Domain: `newsite.jumpstartscaling.com`

2. Add DNS record:
   - Type: A
   - Name: `newsite`
   - Content: `193.122.168.215`

3. Add domain in Coolify:
   - Go to application settings
   - Add `newsite.jumpstartscaling.com`
   - Enable SSL

4. Create pages for new tenant

5. Content automatically filtered by domain!

---

## 🎯 Success Criteria

✅ Payload CMS running on server  
✅ Accessible at `cms.jumpstartscaling.com`  
✅ PostgreSQL database connected  
✅ Admin panel working  
✅ Can create tenants  
✅ Can create pages  
✅ API endpoints functional  
✅ SSL/TLS enabled  
✅ Git repository on GitHub  

---

## 📚 Resources

- **Payload CMS Docs**: https://payloadcms.com/docs
- **Coolify Docs**: https://coolify.io/docs
- **Next.js Docs**: https://nextjs.org/docs
- **PostgreSQL Docs**: https://www.postgresql.org/docs

---

## 🆘 Need Help?

**Common Commands:**

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# View project
cd /home/opc/payload-multitenant && ls -la

# Check git status
git status

# View logs (if running locally)
npm run dev

# Rebuild and restart in Coolify
# Use the UI - click "Redeploy"
```

---

**Created:** January 15, 2026  
**Server:** 193.122.168.215  
**Project Location:** `/home/opc/payload-multitenant`  
**Status:** ✅ Ready for GitHub push and Coolify deployment
