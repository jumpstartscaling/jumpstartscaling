---
description: How to add a new Intel article to the Jumpstart Scaling Astro site
---

# Add a New Intel Article to Jumpstart Scaling

**Site root:** `/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling`

## How Intel Pages Work

- Intel articles are MDX files in `src/content/intel/`
- `src/pages/intel/[...slug].astro` auto-generates a page for each MDX file
- `src/pages/intel/index.astro` auto-discovers all articles and shows them sorted by `publishedAt` (newest first)
- **You do NOT need to edit any routing or listing code** — just create the MDX file and it appears everywhere

## Coding Standards

> [!CAUTION]
> - **No Tailwind CSS** — removed from this project entirely. Use vanilla CSS only
> - **No Three.js or react-three-fiber** — removed for performance
> - **No comments** in MDX files
> - **Do NOT remove content** when editing existing articles — only modify what's requested
> - `GoldenBullets` items must be **strings** (NOT objects) — e.g. `items={["string1", "string2"]}`

## Step 1: Create the MDX File

Create a new file at `src/content/intel/{slug}.mdx` where `{slug}` is the URL-friendly slug (lowercase, hyphens, no spaces).

### Required Frontmatter

```yaml
---
title: "Your Article Title Here"
description: "A 1-2 sentence SEO description of the article (150-160 chars ideal)."
palette: "emerald"
publishedAt: "2026-MM-DD"
author: "Jumpstart Scaling"
category: "Growth Engineering"
tags: ["tag1", "tag2", "tag3"]
---
```

**Schema reference** (`src/content/config.ts`):

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `title` | string | ✅ | Article headline, used in card + page |
| `description` | string | ✅ | Shown on intel listing card + meta tag |
| `palette` | `'gold'` \| `'emerald'` \| `'sapphire'` | No (default `emerald`) | Color theme |
| `publishedAt` | string (date) | ✅ | Format `YYYY-MM-DD`, used for sort order |
| `author` | string | No (default `Jumpstart Scaling`) | Author name |
| `category` | string | No | Category label |
| `tags` | string[] | No | Tag array for future filtering |

## Step 2: Write the MDX Content

Import these Astro components (zero JS, server-rendered):

```mdx
import Hero from '../../components/ui/Hero.astro';
import GlassCard from '../../components/ui/GlassCard.astro';
import GoldenBullets from '../../components/ui/GoldenBullets.astro';
import CTA from '../../components/ui/CTA.astro';
```

### Content Structure Template

Follow this proven pattern (matches existing articles):

```mdx
---
title: "Article Title"
description: "SEO description here."
palette: "emerald"
publishedAt: "2026-02-15"
author: "Jumpstart Scaling"
category: "Growth Engineering"
tags: ["scaling", "strategy"]
---
import Hero from '../../components/ui/Hero.astro';
import GlassCard from '../../components/ui/GlassCard.astro';
import GoldenBullets from '../../components/ui/GoldenBullets.astro';
import CTA from '../../components/ui/CTA.astro';

<Hero title="Article Title" subtitle="A compelling subtitle that hooks the reader." />

<GlassCard title="Section One Heading">

Write long-form content here. Each GlassCard section should be 300-600 words of substantive content. No filler. Use data points, frameworks, and actionable insights.

Second paragraph continues the thought. Build the argument across multiple paragraphs within the same GlassCard.

</GlassCard>

<GlassCard title="Section Two Heading">

Another major section. Aim for 3-5 GlassCard sections per article.

</GlassCard>

<GoldenBullets
  title="Key Takeaways"
  items={[
    "First key takeaway as a plain string",
    "Second key takeaway as a plain string",
    "Third key takeaway as a plain string",
    "Fourth key takeaway as a plain string",
    "Fifth key takeaway as a plain string"
  ]}
/>

<GlassCard title="Final Section Heading">

Wrap up with actionable advice and a bridge to the CTA below.

</GlassCard>

<CTA heading="Ready to Take Action?" text="We build the systems discussed in this article. Start with a free audit." />
```

### Content Rules

> [!IMPORTANT]
> - **2000+ words minimum** per article
> - GlassCard content goes **between** opening and closing tags (slot-based)
> - Leave a **blank line** after `<GlassCard title="...">` and before `</GlassCard>` for MDX parsing
> - Interlink to services/intel where relevant: `[link text](/services/paid-acquisition)` or `[link text](/intel/other-slug)`
> - Do NOT use `className` — use `class` in `.astro` files, or wrap in standard HTML

## Step 3: Verify Locally (Optional)

```bash
cd /Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling
npm run dev
```
Then visit `http://localhost:4321/intel/` to see the new card, and `http://localhost:4321/intel/{slug}/` for the full article.

## Step 4: Deploy

// turbo
1. Sync to server:
```bash
rsync -avz --delete --exclude='node_modules' --exclude='.astro' --exclude='dist' --exclude='.DS_Store' /Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling/src/ opc@193.122.168.215:/home/opc/sites/jumpstartscaling/src/
```

// turbo
2. Build on server:
```bash
ssh opc@193.122.168.215 "cd /home/opc/sites/jumpstartscaling && npm run build 2>&1 | tail -20"
```

// turbo
3. Restart PM2:
```bash
ssh opc@193.122.168.215 "pm2 restart multisite-router"
```

// turbo
4. Verify new article returns 200:
```bash
ssh opc@193.122.168.215 "sleep 2 && curl -s -o /dev/null -w '%{http_code}' http://localhost:8100/intel/{slug}/"
```

Should return `200`. Then visually verify at `https://jumpstartscaling.com/intel/`

## Existing Intel Articles (for reference)

| File | URL |
|------|-----|
| `crm-automation-growth.mdx` | `/intel/crm-automation-growth/` |
| `market-domination-strategy.mdx` | `/intel/market-domination-strategy/` |

## Quick Checklist

- [ ] MDX file created in `src/content/intel/`
- [ ] Frontmatter has all required fields (`title`, `description`, `publishedAt`)
- [ ] Content is 2000+ words
- [ ] Uses `Hero`, `GlassCard`, `GoldenBullets`, `CTA` components
- [ ] `GoldenBullets` items are **strings** not objects
- [ ] No comments, no Tailwind classes
- [ ] Deployed and returns 200
- [ ] Card appears on `/intel/` listing page
