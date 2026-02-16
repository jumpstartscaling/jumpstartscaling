# 🔱 SPARK TECHNICAL AUDIT CHECKLIST

## Frontend Rendering Verification (1,000 Pages)

Use this checklist to ensure your Astro frontend correctly renders all generated pages.

---

## ✅ Phase 1: Schema Validation

### Database Schema
- [ ] `posts` table has all required columns:
  - [ ] `site_id` (UUID/String)
  - [ ] `slug` (String, unique per site)
  - [ ] `title` (String)
  - [ ] `excerpt` (Text, nullable)
  - [ ] `content` (Text/HTML)
  - [ ] `meta_title` (String, max 60 chars)
  - [ ] `meta_description` (String, max 160 chars)
  - [ ] `status` (published/draft)
  - [ ] `created_at` (Timestamp)
  - [ ] `published_at` (Timestamp, nullable)

### Directus API Access
- [ ] API endpoint accessible: `https://office.jumpstartscaling.com/items/posts`
- [ ] Authentication working (bot token or admin token)
- [ ] Can filter by `site_id`
- [ ] Can fetch by `slug`

---

## ✅ Phase 2: Dynamic Routing

### Astro `[...slug].astro` File
- [ ] Located at: `src/pages/[...slug].astro`
- [ ] Imports site context from `Astro.locals.site`
- [ ] Fetches post/page by slug from Directus
- [ ] Handles 404s gracefully
- [ ] Renders with correct theme layout

### Test URLs (Sample 10):
```bash
# Christopher Amaya (001)
curl -I http://chrisamaya.work:4321/headless-crm-austin
curl -I http://chrisamaya.work:4321/best-custom-webapps-in-miami

# Jumpstart Scaling (000)  
curl -I http://jumpstartscaling.com:4321/programmatic-seo-london
curl -I http://jumpstartscaling.com:4321/n8n-automation-experts-nyc

# Masta Codes (002)
curl -I http://masta.codes:4321/ai-agent-development-dubai
curl -I http://masta.codes:4321/vibe-coding-san-francisco
```

**Expected:** All return `200 OK` (not 404)

---

## ✅ Phase 3: SEO Metadata

### Meta Tags Inspection
For each page, verify:
- [ ] `<title>` tag contains `{meta_title}`
- [ ] `<meta name="description">` contains `{meta_description}`
- [ ] `<meta property="og:title">` set
- [ ] `<meta property="og:description">` set
- [ ] `<link rel="canonical">` points to current URL

### Test Command:
```bash
curl -s http://chrisamaya.work:4321/headless-crm-austin | grep -E '<title>|<meta name="description"'
```

**Expected Output:**
```html
<title>Best Headless CRM Austin | Christopher Amaya</title>
<meta name="description" content="Stop using slow systems. Get Headless CRM in Austin instantly.">
```

---

## ✅ Phase 4: Structured Data (Schema.org)

### LocalBusiness Schema (for template-2)
```javascript
// Should appear in pages with local cities
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Christopher Amaya | Spark Architect",
  "address": {
    "@type": "PostalAddress",
    "addressLocality": "Austin",
    "addressRegion": "TX"
  },
  "areaServed": [
    {"@type": "City", "name": "Austin"},
    {"@type": "Landmark", "name": "Texas State Capitol"}
  ]
}
```

### Verification:
```bash
curl -s http://chrisamaya.work:4321/headless-crm-austin | \
  grep -o '<script type="application/ld+json">.*</script>' | \
  python3 -m json.tool
```

- [ ] Valid JSON-LD present
- [ ] `@type` matches page type
- [ ] `addressLocality` matches city from slug
- [ ] `areaServed` includes landmark

---

## ✅ Phase 5: Performance

### Core Web Vitals
Test 5 random pages with Lighthouse:

```bash
npx lighthouse http://chrisamaya.work:4321/headless-crm-austin \
  --only-categories=performance --output=json
```

**Targets:**
- [ ] **LCP** (Largest Contentful Paint): < 2.5s
- [ ] **FID** (First Input Delay): < 100ms
- [ ] **CLS** (Cumulative Layout Shift): < 0.1
- [ ] **Overall Score**: > 90

### Page Speed
```bash
time curl -s -o /dev/null \
  -w "Total: %{time_total}s\n" \
  http://chrisamaya.work:4321/headless-crm-austin
```

- [ ] Response time: < 500ms (local)
- [ ] Response time: < 2s (production)

---

## ✅ Phase 6: Content Quality

### Uniqueness Check
Run a duplicate content detector on 10 random slugs:

```python
import hashlib

pages = [
    "/headless-crm-austin",
    "/headless-crm-miami",
    "/custom-webapps-austin"
]

hashes = {}
for page in pages:
    content = fetch_page_content(page)  # Your implementation
    hash = hashlib.md5(content.encode()).hexdigest()
    
    if hash in hashes:
        print(f"⚠️  DUPLICATE: {page} matches {hashes[hash]}")
    else:
        hashes[hash] = page
        print(f"✅ UNIQUE: {page}")
```

**Goal:** 0 exact duplicates

### Landmark Injection
- [ ] Content includes landmark: "Located near {landmark}"
- [ ] Landmark varies by city
- [ ] Landmark appears in both content AND schema

Sample check:
```bash
curl -s http://chrisamaya.work:4321/headless-crm-austin | \
  grep -i "Texas State Capitol"
```

---

## ✅ Phase 7: Internal Linking

### Cross-Linking Strategy
Every 10th page should link back to an authority article.

**Pattern:**
- Pages 1-10: Link to `/the-architects-manifesto`
- Pages 11-20: Link to `/ultimate-guide-to-pseo-2025`
- Pages 21-30: Link to `/vibe-coding-agentic-workflows`

### Verification:
```bash
# Check if page 5 links to manifesto
curl -s http://chrisamaya.work:4321/best-headless-crm-in-austin | \
  grep -o 'href="/the-architects-manifesto"'
```

- [ ] Internal links present
- [ ] Link rel="nofollow" NOT set on internal links
- [ ] Links point to published pages

---

## ✅ Phase 8: Mobile Responsiveness

### Viewport Test
```bash
curl -s -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 14_0)" \
  http://chrisamaya.work:4321/headless-crm-austin | \
  grep 'viewport'
```

**Expected:**
```html
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

### Mobile Performance
Run Lighthouse mobile:
```bash
npx lighthouse http://chrisamaya.work:4321/headless-crm-austin \
  --preset=desktop --output=json
```

- [ ] Mobile score > 85
- [ ] No horizontal scroll
- [ ] Touch targets > 48px

---

## ✅ Phase 9: Indexability

### Robots.txt
```bash
curl http://chrisamaya.work:4321/robots.txt
```

**Should contain:**
```
User-agent: *
Allow: /

Sitemap: https://chrisamaya.work/sitemap.xml
```

- [ ] No blanket `Disallow: /`
- [ ] Sitemap linked
- [ ] Critical paths not blocked

### Sitemap.xml
```bash
curl http://chrisamaya.work:4321/sitemap.xml | grep -c '<url>'
```

- [ ] Contains at least 1,000 URLs
- [ ] All URLs use HTTPS (production)
- [ ] Valid XML format

---

## ✅ Phase 10: Error Handling

### 404 Pages
```bash
curl -I http://chrisamaya.work:4321/this-page-does-not-exist
```

- [ ] Returns `404 Not Found` status
- [ ] Shows custom 404 page (not blank)
- [ ] Includes navigation to homepage

### 500 Errors
- [ ] No pages throw 500 errors
- [ ] API failures fail gracefully
- [ ] Error messages logged (not displayed to user)

---

## 🎯 Final Verification Matrix

| Check | Expected | Status |
|-------|----------|--------|
| Total pages generated | 1,000+ | [ ] |
| Pages accessible via URL | 100% | [ ] |
| Unique meta titles | 100% | [ ] |
| Unique meta descriptions | 100% | [ ] |
| Valid schema markup | 100% | [ ] |
| Internal links functional | 100% | [ ] |
| Lighthouse score > 90 | Sample of 10 | [ ] |
| Mobile responsive | 100% | [ ] |
| Indexed in sitemap.xml | 100% | [ ] |

---

## 🚀 Production Deployment Checklist

Before pushing to live:

- [ ] Run all verification steps above
- [ ] Test on staging environment
- [ ] Verify DNS for all 3 domains
- [ ] SSL certificates active
- [ ] CDN configured (if using)
- [ ] Google Search Console verified
- [ ] Submit sitemap to GSC
- [ ] Monitor first 24h for errors

---

## 📊 Post-Launch Monitoring

### Week 1:
- [ ] Check Google Search Console for indexation
- [ ] Monitor 404 errors
- [ ] Track Core Web Vitals
- [ ] Review search impressions

### Week 2-4:
- [ ] Track keyword rankings
- [ ] Monitor organic traffic
- [ ] Review CTR in GSC
- [ ] Identify top-performing pages

---

**Use this checklist to ensure your 1,000-page pSEO deployment is flawless!** 🔱✨
