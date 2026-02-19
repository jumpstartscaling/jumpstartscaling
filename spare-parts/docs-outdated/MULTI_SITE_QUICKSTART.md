# 🚀 MULT-SITE SYSTEM - QUICK START GUIDE

## ✅ What's Been Built

I've created a complete multi-site system for God Mode:

### Files Created:
1. **`src/middleware.ts`** - Multi-site domain routing
2. **`src/pages/[...slug].astro`** - Dynamic page router
3. **`src/themes/blog/layouts/BlogLayout.astro`** - Blog theme
4. **`src/themes/business/layouts/BusinessLayout.astro`** - Business theme
5. **`src/themes/portfolio/layouts/PortfolioLayout.astro`** - Portfolio theme
6. **`src/themes/minimal/layouts/MinimalLayout.astro`** - Minimal theme
7. **`god_architect_local/seed_example_sites.py`** - Site seeder (needs manual creation for now)

---

## 🎯 How It Works

1. **User visits a domain** (e.g., `techblog.local`)
2. **Middleware detects the domain**
3. **Queries Directus** for site configuration
4. **Loads appropriate theme** (blog, business, portfolio, minimal)
5. **Fetches page content** from Directus
6. **Renders with theme** and serves to user

---

## 📝 Manual Setup (Until Seeder is Fixed)

### Step 1: Create a Site in Directus

1. Visit: https://office.jumpstartscaling.com
2. Go to **Content → Sites**
3. Click **Create Item** (+)
4. Fill in:
   - **domain**: `techblog.local`
   - **name**: `TechVibe Blog`
   - **type**: `blog`
   - **theme**: `modern-blog`
   - **status**: `active`
   - **config** (JSON):
     ```json
     {
       "primaryColor": "#3B82F6",
       "font": "Inter",
       "about": "A blog about web development",
       "email": "hello@techvibe.local"
     }
     ```

5. Click **Save**

### Step 2: Create Pages

1. Go to **Content → Pages**
2. Click **Create Item** (+)
3. Fill in:
   - **site_id**: Select "TechVibe Blog"
   - **slug**: `/`
   - **title**: `Home`
   - **content**:
     ```html
     <h1>Welcome to TechVibe</h1>
     <p>Your source for web development tutorials.</p>
     ```
   - **status**: `published`

4. Create more pages (`/about`, `/contact`, etc.)

### Step 3: Add to /etc/hosts

```bash
sudo nano /etc/hosts
```

Add line:
```
127.0.0.1 techblog.local
```

Save and exit.

### Step 4: Test Locally

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
npm run dev
```

Visit: **http://techblog.local:4321**

You should see your site with the blog theme! 🎉

---

## 🌐 Creating More Sites

Repeat the process for different site types:

### Business Site
```json
{
  "domain": "designco.local",
  "name": "DesignCo Agency",
  "type": "business",
  "theme": "clean-business",
  "status": "active",
  "config": {
    "primaryColor": "#10B981",
    "tagline": "Transform your brand"
  }
}
```

### Portfolio Site
```json
{
  "domain": "portfolio.local",
  "name": "Jane Doe",
  "type": "portfolio",
  "theme": "minimal-portfolio",
  "status": "active",
  "config": {
    "primaryColor": "#EC4899",
    "tagline": "Designer & Developer"
  }
}
```

---

## 🚀 Production Deployment

### For Real Domains:

1. **Create site in Directus with real domain**
   - domain: `myblog.com`

2. **Point DNS A record**
   - `myblog.com` → Your server IP

3. **Deploy God Mode**
   - Push to git
   - Coolify auto-deploys

4. **Test**
   - Visit `myblog.com`
   - Should load from Directus!

---

## ✨ Features

- ✅ **Multi-tenant** - One codebase, infinite sites
- ✅ **Theme system** - Blog, business, portfolio, minimal
- ✅ **Directus CMS** - Manage everything visually
- ✅ **Domain routing** - Automatic detection
- ✅ **Dynamic content** - All from database
- ✅ **Zero deploys** - Add sites without code changes

---

## 🐛 Troubleshooting

### Site not found
- Check domain matches exactly in Directus
- Check status is "active"
- Clear cache/restart dev server

### Page shows 404
- Verify page exists in Directus
- Check site_id is correct
- Check slug matches URL

### Theme not applying
- Check site type is set correctly
- Verify theme file exists in `/src/themes/`

---

## 📚 Next Steps

1. ✅ **Create your first site** (follow steps above)
2. ✅ **Test locally** with .local domains
3. ✅ **Add content** in Directus
4. ✅ **Connect real domain** when ready
5. ✅ **Scale infinitely!**

---

**The system is ready! Start creating sites in Directus and watch them come to life!** 🎉
