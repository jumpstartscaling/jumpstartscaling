---
description: How to update the main pages, header, and footer for the Jumpstart Scaling Astro site
---

# Update Jumpstart Scaling Main Pages, Header & Footer

**Site root:** `/Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling`

## Architecture Quick Reference

| Component | File Path |
|-----------|-----------|
| Header/Nav | `src/components/ui/Navigation.astro` |
| Footer | `src/components/ui/Footer.astro` |
| Base Layout | `src/layouts/BaseLayout.astro` |
| Homepage | `src/pages/index.astro` |
| About | `src/pages/about.astro` |
| Contact | `src/pages/contact.astro` |
| Audit | `src/pages/audit.astro` |
| Privacy | `src/pages/privacy.astro` |
| Terms | `src/pages/terms.astro` |
| 404 | `src/pages/404.astro` |
| Global CSS | `src/styles/global.css` |
| Astro Config | `astro.config.mjs` |
| Server Router | `/home/opc/sites/router.js` (on server) |

## Coding Standards

> [!CAUTION]
> ALL code must follow these rules exactly:
> - **Minified** — no unnecessary whitespace, no blank lines between code
> - **No comments** — zero comments in any file
> - **No syntax errors** — triple-check all curly braces, parentheses, template literals
> - **No Tailwind classes** — Tailwind has been fully removed from this project
> - **Vanilla CSS only** — use custom CSS with CSS variables from `global.css`
> - **No `<` comparisons in JSX** — use pre-computed booleans (esbuild can't parse `i<arr.length` inside `.astro` files)
> - **No Three.js / react-three-fiber** — removed for performance. Use CSS animations instead
> - **Do NOT remove content** when refactoring components — only swap component wrappers, never delete text

## CSS Variables (from global.css)

```
--bg: #050505
--surface: #0A0A0A
--border: rgba(255,255,255,0.06)
--text-primary: #F5F5F5
--text-secondary: #888
--accent: var(--palette-accent)  (defaults to gold #C9A961)
--accent-dim: var(--palette-accent-dim)
--gradient-accent: linear-gradient(135deg, var(--palette-accent), var(--palette-accent-light))
```

Palette options set via `html[data-palette]`: `gold` (default), `emerald`, `sapphire`

## Performance Rules

> [!IMPORTANT]
> - **No Three.js or react-three-fiber** — particle effects use CSS-only `AtmosphereParticles.astro`
> - **No Tailwind CSS** — removed from `global.css`, `astro.config.mjs`, and vite plugins
> - **Minimize React components** — only use `client:load` or `client:visible` when interactivity is absolutely required (e.g. `ScalingSurvey.jsx`)
> - **Astro components preferred** — server-rendered `.astro` components ship zero JS
> - **Router serves gzip** — `router.js` compresses HTML/CSS/JS/JSON/SVG automatically
> - **Fonts cached 1 year** — `.woff`/`.woff2` served with `max-age=31536000, immutable`
> - **Astro assets cached forever** — `/_astro/` paths are content-hashed with immutable cache

## Steps to Update Navigation (Header)

1. Open `src/components/ui/Navigation.astro`
2. The `services` array (lines 4-11) defines the Services dropdown. Add/remove/rename items here.
3. The desktop nav links are in `<ul class="nav-links">` — add new `<li>` entries with `<a>` tags
4. The mobile drawer links are in `<ul class="mob-links">` — keep these in sync with desktop
5. Use `class:list={['nav-link',{active:currentPath==='/your-path'}]}` for active state

## Steps to Update Footer

1. Open `src/components/ui/Footer.astro`
2. The footer has 4 columns defined in `.ft-grid`:
   - **Brand** — company name + description
   - **Services** — auto-generated from the `services` array in frontmatter
   - **Resources** — manual links (Intel, Audit, About, Contact)
   - **Legal** — Privacy, Terms + email
3. To add footer links, add `<li><a href="/path">Label</a></li>` to the appropriate `<ul class="ft-list">`

## Steps to Update a Main Page

1. All pages use `<BaseLayout>` which wraps content with Navigation + Footer
2. BaseLayout accepts these props:
   ```
   title: string (required — used for <title> tag)
   description: string (required — used for meta description)
   palette: 'gold' | 'emerald' | 'sapphire' (optional, default 'gold')
   canonical: string (optional — canonical URL override)
   type: 'WebPage' | 'Article' | 'Service' | 'FAQPage' (optional)
   crumbs: {name:string, url:string}[] (optional — breadcrumb schema)
   faqs: {q:string, a:string}[] (optional — FAQ schema markup)
   noindex: boolean (optional — prevents indexing)
   ```
3. Available UI components (all Astro, zero JS):
   - `Hero` — `title` + `subtitle` props, accepts child slot
   - `GlassCard` — `title` prop, accepts child content (slot)
   - `GoldenBullets` — `items` prop (**string array only**), optional `title` and `columns` props
   - `CTA` — `heading` + `text` props
   - `SectionHeading` — `title` + `subtitle` props
   - `Breadcrumbs` — `items` prop ({name, url}[])
   - `ServiceTeaser` — `title`, `description`, `slug`, optional `metrics` props
   - `AtmosphereParticles` — CSS-only particle background (no client directive needed)
4. React components (use sparingly, only when interactivity needed):
   - `ScalingSurvey` — use with `client:visible`
   - `MoatAudit` — use with `client:visible`

## Deploy After Changes

// turbo
1. Sync source to server:
```bash
rsync -avz --delete --exclude='node_modules' --exclude='.astro' --exclude='dist' --exclude='.DS_Store' /Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling/src/ opc@193.122.168.215:/home/opc/sites/jumpstartscaling/src/
```

// turbo
2. If `astro.config.mjs` changed, sync it too:
```bash
rsync -avz /Users/christopheramaya/Downloads/spark/god-mode/sites/jumpstartscaling/astro.config.mjs opc@193.122.168.215:/home/opc/sites/jumpstartscaling/astro.config.mjs
```

// turbo
3. Build on server:
```bash
ssh opc@193.122.168.215 "cd /home/opc/sites/jumpstartscaling && npm run build 2>&1 | tail -20"
```

// turbo
4. Restart PM2:
```bash
ssh opc@193.122.168.215 "pm2 restart multisite-router"
```

// turbo
5. Verify all pages return 200:
```bash
ssh opc@193.122.168.215 "sleep 2 && for p in '/' '/about/' '/contact/' '/audit/' '/privacy/' '/terms/' '/intel/' '/services/paid-acquisition/' '/services/authority-engine/' '/services/crm-transformation/' '/services/data-attribution/' '/services/funnel-architecture/' '/services/growth-retainer/' '/intel/crm-automation-growth/' '/intel/market-domination-strategy/'; do code=\$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8100\$p); echo \"\$code \$p\"; done"
```

All should return `200`. Then visually verify at https://jumpstartscaling.com

## If Updating router.js

The server router lives at `/home/opc/sites/router.js` (NOT `/home/opc/router.js`). To deploy router changes:

```bash
rsync -avz /Users/christopheramaya/Downloads/spark/god-mode/router.js opc@193.122.168.215:/home/opc/sites/router.js
ssh opc@193.122.168.215 "pm2 restart multisite-router"
```
