# 🔗 PREVIEW LINKS FOR chrisamaya.work

## ✅ Your Site Info:
- **Name:** caw
- **Domain:** chrisamaya.work
- **Site ID:** 54321789-0000-0000-0000-000000000001
- **Status:** Active ✅

---

## 📝 CREATE CONTENT IN DIRECTUS UI

### Step 1: Create a Home Page

1. **Visit:** https://office.jumpstartscaling.com
2. **Go to:** Content → Pages
3. **Click:** Create Item (+)
4. **Fill in:**
   - **site_id:** Select "caw" (chrisamaya.work)
   - **slug:** `/`
   - **title:** `Welcome to chrisamaya.work`
   - **content:**
   ```html
   <div style="text-align: center; padding: 4rem 2rem;">
       <h1 style="font-size: 3.5rem; font-weight: 900;">Christopher Amaya</h1>
       <p style="font-size: 1.5rem; color: #6B7280;">
           Building the future of digital experiences
       </p>
   </div>
   ```

5. **Click:** Save

### Step 2: Create an About Page

Same process, but:
- **slug:** `/about`
- **title:** `About`
- **content:**
```html
<h1>About Me</h1>
<p>I'm Christopher Amaya, and this is my personal website.</p>
```

### Step 3: Create a Blog Post

1. **Go to:** Content → Posts
2. **Click:** Create Item (+)
3. **Fill in:**
   - **site_id:** Select "caw"
   - **slug:** `/my-first-post`
   - **title:** `My First Post`
   - **excerpt:** `Testing the multi-site system`
   - **content:**
   ```html
   <h1>My First Post</h1>
   <p>This is my first blog post on my new site!</p>
   ```

4. **Click:** Save

---

## 🔗 YOUR PREVIEW LINKS

Once you create the content above, these links will work:

### Pages:
- **Home:** http://chrisamaya.work/
- **About:** http://chrisamaya.work/about
- **Contact:** http://chrisamaya.work/contact

### Posts:
- **First Post:** http://chrisamaya.work/my-first-post

---

## 🚀 TEST LOCALLY

### 1. Add to /etc/hosts

```bash
sudo sh -c 'echo "127.0.0.1 chrisamaya.work" >> /etc/hosts'
```

### 2. Run God Mode

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
npm run dev
```

### 3. Visit Your Site

Open: **http://chrisamaya.work:4321**

You should see your homepage! 🎉

---

## 🌐 DEPLOY TO PRODUCTION

When ready to go live:

### 1. Point DNS

Add an A record:
```
chrisamaya.work → your server IP
```

### 2. Deploy God Mode

```bash
git add .
git commit -m "feat: multi-site system ready"
git push origin main
```

Coolify will auto-deploy!

### 3. Visit Live Site

**https://chrisamaya.work** 

Your site will be live! 🌍

---

## 🎨 CUSTOMIZE YOUR SITE

Edit the site in Directus to change:

1. **Type:** `blog`, `business`, `portfolio`, `minimal`
2. **Theme:** Changes the visual design
3. **Config (JSON):**
```json
{
  "primaryColor": "#3B82F6",
  "font": "Inter",
  "about": "Your tagline here",
  "email": "hello@chrisamaya.work"
}
```

The site will automatically update! No code changes needed! ✨

---

**Your multi-site system is ready! Just add content in Directus and watch it appear!** 🔱
