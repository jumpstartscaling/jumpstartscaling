# 🔱 SPARK COMPREHENSIVE DATA IMPORT - REFERENCE GUIDE

## ✅ What's Been Created:

### 1. Utilities (`src/utils/spintax.js`)
- ✅ Spintax parser for {option1|option2} format
- ✅ Localized slug generator for pSEO
- ✅ Russell Bullet randomizer

### 2. Campaign Data (`campaigns_and_avatars.json`)
**4 pSEO Campaigns:**
- JS-AUTHORITY-Q4 (Jumpstart Scaling - 500 pages)
- CA-LOCAL-MIAMI (Christopher Amaya - 100 local pages)
- MC-AFFILIATE-AI (Masta Codes - 250 review pages)
- MC-SNIPPET-LIST (Masta Codes - 150 featured snippet pages)

**Avatar & Targeting Data:**
- Christopher Amaya (Austin, TX + landmarks)
- Jumpstart Growth Bot (Global/Remote)
- Masta Intelligence (Virtual/Metaverse)

### 3. Content Templates (`content_templates.json`)
**5 High-Value Templates:**
1. The Death of Manual SEO (Jumpstart)
2. Shadow Worker AI Review (Masta)
3. Austin Headless Consulting (Christopher)
4. The Architect's Manifesto (Christopher)
5. Vibe Coding & Agentic Workflows (Masta)

---

## 📊 Data Breakdown:

### Campaigns (4 total):
```
JS-AUTHORITY-Q4     → 500 authority pages
CA-LOCAL-MIAMI      → 100 local SEO pages
MC-AFFILIATE-AI     → 250 affiliate reviews
MC-SNIPPET-LIST     → 150 featured snippets
────────────────────
TOTAL POTENTIAL:     1,000 pages
```

### Russell Bullets (per site):
- chrisamaya.work: 6 variations
- jumpstartscaling.com: 4 variations
- masta.codes: 4 variations

### Geo-Targeting:
- Austin Landmarks: Barton Springs, Capitol, Frost Bank Tower
- Neighborhoods: Zilker, Tarrytown, Mueller
- Zip Codes: 78701, 78704, 78703

---

## 🎯 How To Use:

### Option 1: Generate Localized Slugs

```javascript
import { generateLocalizedSlugs } from '/utils/spintax';

const services = ["Headless CRM", "Spark Architecture", "Custom Apps"];
const locations = [
  {city: "Austin"},
  {city: "Round Rock"},
  {city: "West Lake Hills"}
];

const slugs = generateLocalizedSlugs(services, locations);
// Returns: headless-crm-austin, headless-crm-near-austin, best-headless-crm-austin, etc.
```

### Option 2: Parse Russell Bullets

```javascript
import { getRussellBullet } from '/utils/spintax';

const bullets = [
  "{The 'Barton Springs' Speed|The Zilker Hack}: {Apps that load fast|My exact method}."
];

const randomBullet = getRussellBullet(bullets);
// Returns: "The Zilker Hack: My exact method."
```

### Option 3: Use in Astro Templates

```astro
---
import { parseSpintax } from '@/utils/spintax';
import avatars from '@/data/campaigns_and_avatars.json';

const site = avatars.avatars_and_targeting.find(s => s.domain === "chrisamaya.work");
const bullet = parseSpintax(site.seo.russell_bullets[0]);
---

<div class="local-seo">
  <h2>{site.entity.name} in {site.entity.geo.city}</h2>
  <p>{bullet}</p>
  <ul>
    {site.entity.geo.landmarks.map(landmark => (
      <li>Near {landmark}</li>
    ))}
  </ul>
</div>
```

---

## 📝 Content Creation Workflow:

### For 1,000 Page Batch:

1. **Load Campaign Data**
   ```javascript
   import campaigns from './campaigns_and_avatars.json';
   const campaign = campaigns.campaigns.find(c => c.campaign_id === "JS-AUTHORITY-Q4");
   ```

2. **Generate Slugs**
   ```javascript
   const services = campaign.settings.keywords;
   const locations = [/* your geo data */];
   const slugs = generateLocalizedSlugs(services, locations);
   ```

3. **For Each Slug, Create Page:**
   ```javascript
   slugs.forEach(slug => {
     const page = {
       site_id: campaign.site_id,
       slug: `/${slug}`,
       title: parseSpintax(metaTemplate),
       content: parseSpintax(contentTemplate),
       status: "published"
     };
     // Import to Directus
   });
   ```

---

## 🖼️ Image Generation:

All templates include `image_gen_prompt` fields:

**For Jumpstart Scaling:**
```
"Futuristic server room with blue neon 'Spark' energy flowing between racks, high-tech, cinematic lighting, 8k, hyper-realistic, blue and slate grey palette."
```

**For Masta Codes:**
```
"A futuristic digital brain made of emerald green fiber-optic cables, floating in a dark server room, data streams as glowing green binary, 8k, Unreal Engine 5 render, cyberpunk mood."
```

**For Christopher Amaya:**
```
"Cinematic portrait of a male developer in a dark minimalist studio, surrounded by floating translucent code windows and architectural blueprints, blue and indigo lighting, sharp focus, professional photography."
```

Use these in:
- Midjourney: `/imagine [prompt] --ar 16:9 --v 6`
- DALL-E 3: Direct paste
- Stable Diffusion: Add your model-specific parameters

---

## 🔗 Schema Integration:

### LocalBusiness Example:
```json
{
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "Christopher Amaya | Spark Architect",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "800 Brazos St",
    "addressLocality": "Austin",
    "addressRegion": "TX",
    "postalCode": "78701"
  },
  "telephone": "(512) 555-0142",
  "areaServed": [
    {"@type": "City", "name": "Austin"},
    {"@type": "Neighborhood", "name": "Zilker"},
    {"@type": "Landmark", "name": "Barton Springs Pool"}
  ]
}
```

---

## 🚀 Next Steps:

1. **Import Campaigns** into Directus (coming in next batch)
2. **Generate Slug Variations** using spintax utility
3. **Create Content Templates** for each campaign type
4. **Batch Create Pages** (1,000+ ready for deployment)
5. **Generate Featured Images** using prompts provided

---

**All data is schema-compliant and ready for import! No database changes needed.** 🔱✨

---

## 📚 File References:

- **Spintax Utility:** `src/utils/spintax.js`
- **Campaigns:** `god_architect_local/campaigns_and_avatars.json` (deprecated; content now in `spark/exports/`)
- **Templates:** `god_architect_local/content_templates.json` (deprecated)
- **Previous Sites:** `god_architect_local/import_full_data.json` (deprecated)

**Note:** `god_architect_local/` is deprecated. For PostgreSQL seeding, use `spark/exports/` (geo_intelligence, generation_jobs) and `python-api/scripts/seed_from_exports.py`.

**Total Content Ready:** 1,000+ pages across 3 sites! 🎉
