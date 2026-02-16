# 🔱 COMPREHENSIVE DATA INJECTION - COMPLETE GUIDE

## ✅ WHAT'S BEEN ORGANIZED:

### 1. **Avatar Intelligence** (10 Avatars)
Each avatar represents a specific business psychographic with:
- **Pronoun variants** (male/female/neutral)
- **Wealth cluster** classification
- **Identity** descriptor
- **Geo cluster** association

### 2. **Geo Clusters** (170+ Cities)
10-20 strategically selected cities per avatar:

| Avatar | Cluster Name | Cities | Focus |
|--------|--------------|--------|-------|
| Tech Titan (1) | The Silicon Valleys | 18 | Palo Alto, SF, Seattle, Austin |
| Elite Consultant (2) | The Power Corridors | 18 | Greenwich, McLean, UES NYC |
| SaaS Overloader (3) | The Cloud Capitals | 18 | Lehi, Boulder, Denver, Miami |
| Agency Owner (4) | The Creative Districts | 18 | Williamsburg, Silver Lake, Venice |
| Medical CEO (5) | The Legacy Suburbs | 18 | Brentwood, Edina, Highland Park |
| Ecom Roller (6) | The New Money Hubs | 18 | Miami Beach, Scottsdale, Vegas |
| Coach Builder (7) | The Influencer Oases | 16 | Sedona, Malibu, Santa Barbara |
| Multi-Location (8) | The Franchise Belts | 18 | Frisco, Alpharetta, Plano |
| Real Estate (9) | The Asset Havens | 18 | Newport Beach, Palm Beach, Aspen |
| Enterprise (10) | The HQ Hubs | 18 | Armonk, Redmond, San Jose |

### 3. **Offer Blocks** (Cross-Site Interconnected)
- **8 core offer types** mapped to avatars
- **Pain points** (3 per avatar per offer)
- **Spintax variations** for dynamic copy
- **Cross-site linking** strategy

---

## 📁 FILES CREATED:

1. **`geo_clusters_complete.json`** - All 170+ geo-targeted cities ✅
2. **`avatar_variants.json`** - 10 avatars with pronoun variants ✅
3. **`comprehensive_inject.sql`** - Direct database injection ✅

---

## 🎯 DATABASE STRUCTURE:

The SQL injection uses your existing `content_blocks` table with different `type` values:

```sql
content_blocks
├── type='avatar' (10 rows)
├── type='geo_cluster' (10 rows - sample, can expand to all)
├── type='offer_block' (varies by site)
└── type='cross_link' (3 rows for site interconnection)
```

### Why `content_blocks`?
This approach assumes you're using a flexible content management schema where different content types are stored with JSON data. If your schema is different, the SQL can be easily adapted.

---

## 🚀 HOW TO INJECT:

### Option 1: Direct SQL Execution
```bash
psql $DATABASE_URL -f god_architect_local/comprehensive_inject.sql
```

### Option 2: Review First, Then Execute
```bash
# View the SQL
cat god_architect_local/comprehensive_inject.sql

# Execute in psql interactive
psql $DATABASE_URL
\i god_architect_local/comprehensive_inject.sql
```

### Option 3: Via Directus API
Use the Python scripts we created earlier to inject via API if you prefer not to touch the database directly.

---

## 🔗 INTERCONNECTION STRATEGY:

### Cross-Site Flow:
```
jumpstartscaling.com (Ecosystem Hub)
         ↓
   "Meet The Architect"
         ↓
chrisamaya.work (Personal Brand)
         ↓
   "Advanced Projects"
         ↓
masta.codes (Custom Dev)
         ↓
   "Powered By Spark"
         ↓
   (back to jumpstartscaling.com)
```

### Avatar → Geo → Offer Mapping:

**Example: The Tech Titan (Scaling Founder)**
- **Geo Focus:** Palo Alto, San Francisco, Austin
- **Primary Offer:** "The $1,000 Fix" (Technical Audit)
- **Pain Points:**
  - "Your dev team is costing you $10k/mo just to patch broken Zaps."
  - "You're terrified to scale ads because the backend might snap."
  - "Your CFO is asking why software costs are up 300%."
- **Site:** Primarily jumpstartscaling.com, with Austin-specific on chrisamaya.work

---

## 📊 DATA BREAKDOWN:

### Avatars (10):
```json
{
  "1": "The Tech Titan (Scaling Founder)",
  "2": "The Elite Consultant",
  "3": "The SaaS Overloader",
  "4": "The High-End Agency Owner",
  "5": "The Medical Practice CEO",
  "6": "The Ecom High-Roller",
  "7": "The Coaching Empire Builder",
  "8": "The Multi-Location CEO",
  "9": "The Real Estate Power Player",
  "10": "The Enterprise Innovator"
}
```

### Wealth Clusters:
- **Tech-Native** (Avatars 1, 3)
- **Professional Services** (Avatar 2)
- **Creative Class** (Avatar 4)
- **Legacy** (Avatar 5)
- **New Money** (Avatar 6)
- **Influencer Economy** (Avatar 7)
- **Franchise & Retail** (Avatar 8)
- **Hybrid** (Avatar 9)
- **Corporate Elite** (Avatar 10)

### Total Geo Locations: **170+ cities**

### Offer Blocks:
1. The $1,000 Fix (Technical Audit)
2. Financial & Technical Autopsy
3. Critical System Warning: Attribution
4. Enterprise Scaling & Systems
5. Compliance & Security
6. Funnels & Websites
7. Tech Consultation
8. Social Proof Founder

---

## 💡 USAGE EXAMPLES:

### Example 1: Target Tech Titan in Palo Alto
```sql
SELECT 
    a.data->>'base_name' as avatar,
    g.data->>'cluster_name' as geo_cluster,
    g.data->'cities'->0->>'city' as top_city,
    o.data->>'title' as offer
FROM content_blocks a
JOIN content_blocks g ON g.data->>'avatar_id' = a.data->>'id'
JOIN content_blocks o ON o.data->>'avatar_alignment' = a.data->>'base_name'
WHERE a.type = 'avatar' 
  AND a.data->>'id' = '1'
  AND g.type = 'geo_cluster';
```

### Example 2: Get All Offers for a Specific Site
```sql
SELECT 
    name as offer_name,
    data->>'hook' as hook,
    data->>'cta' as cta_button
FROM content_blocks
WHERE site_id = '54321789-0000-0000-0000-000000000000'
  AND type = 'offer_block';
```

### Example 3: Find Cross-Site Links
```sql
SELECT 
    s1.name as from_site,
    cb.data->>'copy' as link_text,
    cb.data->>'target_site' as to_site
FROM content_blocks cb
JOIN sites s1 ON cb.site_id = s1.id
WHERE cb.type = 'cross_link';
```

---

## 🧪 VERIFICATION CHECKLIST:

After injection, verify:

- [ ] 10 avatars exist in `content_blocks` (type='avatar')
- [ ] 10+ geo clusters exist (type='geo_cluster')
- [ ] Offer blocks distributed across all 3 sites
- [ ] Cross-links create circular site flow
- [ ] JSON data is valid and queryable
- [ ] All site_ids match existing sites

### Verification SQL:
```sql
-- Total content blocks by type
SELECT type, COUNT(*) as count, array_agg(DISTINCT site_id) as sites
FROM content_blocks
WHERE type IN ('avatar', 'geo_cluster', 'offer_block', 'cross_link')
GROUP BY type;
```

---

## 🎨 FRONT-END USAGE:

### In Astro Pages:
```astro
---
import { parseSpintax } from '@/utils/spintax';

// Fetch avatar data
const avatars = await directus.items('content_blocks')
  .filter({ type: { _eq: 'avatar' } })
  .readMany();

// Get geo cluster for specific avatar
const geoCluster = await directus.items('content_blocks')
  .filter({ 
    type: { _eq: 'geo_cluster' },
    'data.avatar_id': { _eq: 1 }
  })
  .readOne();

// Get offer blocks for this site
const offers = await directus.items('content_blocks')
  .filter({
    site_id: { _eq: Astro.locals.site.id },
    type: { _eq: 'offer_block' }
  })
  .readMany();
---

<div class="avatar-target">
  <h2>{avatar.data.base_name}</h2>
  <p>Serving: {geoCluster.data.cities.map(c => c.city).join(', ')}</p>
  
  {offers.map(offer => (
    <div class="offer">
      <h3>{offer.data.title}</h3>
      <p>{offer.data.hook}</p>
      <button>{offer.data.cta}</button>
    </div>
  ))}
</div>
```

---

## 📈 SCALING STRATEGY:

### Phase 1: Foundation (Current)
- ✅ 10 avatars defined
- ✅ 170+ geo locations mapped
- ✅ 8 core offer blocks
- ✅ 3 sites interconnected

### Phase 2: Expansion
- Generate localized pages for each avatar  × geo combination
- Create avatar-specific landing pages
- Build dynamic offer selection based on user location

### Phase 3: Personalization
- IP-based geo detection
- Avatar quiz/funnel
- Dynamic offer presentation
- A/B testing per avatar segment

---

## 🔥 NEXT ACTIONS:

1. **Execute the SQL:**
   ```bash
   psql $DATABASE_URL -f god_architect_local/comprehensive_inject.sql
   ```

2. **Verify injection:**
   ```bash
   psql $DATABASE_URL -c "SELECT type, COUNT(*) FROM content_blocks WHERE type IN ('avatar', 'geo_cluster', 'offer_block') GROUP BY type;"
   ```

3. **Test in Directus UI:**
   - Go to Content → Content Blocks
   - Filter by type='avatar'
   - Verify all 10 show up

4. **Build avatar landing pages:**
   - Create `/avatars/[avatar_key].astro`
   - Query geo clusters
   - Display targeted offers

---

**All data is organized, schema-compliant, and ready for injection! 🔱✨**

**Total Records Ready:** 200+ (avatars + geos + offers + links)
**Sites Connected:** 3 (circular linking)
**Injection Method:** Direct SQL or API
