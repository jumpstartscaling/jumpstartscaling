# 📁 God Mode - Complete Folder Structure Breakdown

## 🎯 Overview
This document provides a comprehensive breakdown of every major folder in God Mode, explaining their purpose, contents, and relationships.

---

## 📚 **1. `src/lib/` - Core Library & Utilities** (19 subdirs, 7 files)

**Purpose:** Central nervous system of God Mode - all shared logic, utilities, and integrations

### **📂 Structure:**

#### **Database & Data Access:**
- **`db/` (3 files)** - PostgreSQL connection management
  - `pool.ts` - Connection pooling
  - `queries.ts` - Query builders
  - `migrations.ts` - Schema migrations

- **`db.ts`** - Main database client (508 bytes)
  - Exports pool instance
  - Connection string management

#### **Directus Integration:**
- **`directus/` (4 files)** - Directus CMS client
  - `client.ts` - SDK initialization
  - `queries.ts` - Directus query builders
  - `mutations.ts` - Content updates
  - `types.ts` - Directus type definitions

- **`directus-enhanced.ts`** (532 bytes) - Enhanced Directus client with logging

#### **Content Generation:**
- **`cartesian/` (6 files)** - Cartesian product content generation
  - `generator.ts` - Main generation engine
  - `combinator.ts` - Variable combination logic
  - `templates.ts` - Template processing
  - `validators.ts` - Output validation
  - `patterns.ts` - Pattern matching
  - `utils.ts` - Helper functions

- **`assembler/` (6 files)** - Content assembly pipeline
  - `pipeline.ts` - Assembly workflow
  - `blocks.ts` - Block management
  - `renderer.ts` - Content rendering
  - `optimizer.ts` - Output optimization
  - `quality.ts` - QA checks
  - `export.ts` - Export formats

#### **Queue System:**
- **`queue/` (2 files)** - BullMQ job queue
  - `jobs.ts` - Job definitions
  - `workers.ts` - Worker processes

#### **Intelligence & Analytics:**
- **`intelligence/` (1 file)** - AI/ML utilities
  - `avatars.ts` - Persona management

- **`analytics/` (2 files)** - Tracking & metrics
  - `events.ts` - Event tracking
  - `metrics.ts` - Performance metrics

#### **Templates & Variables:**
- **`templates/` (1 file)** - Template management
  - `loader.ts` - Template loading/parsing

- **`variables/` (3 files)** - Variable replacement
  - `parser.ts` - Variable parsing
  - `resolver.ts` - Variable resolution
  - `registry.ts` - Variable registry

- **`spintax/` (1 file)** - Text spinning
  - `engine.ts` - Spintax processor

#### **SEO & WordPress:**
- **`seo/` (3 files)** - SEO utilities
  - `meta.ts` - Meta tag generation
  - `schema.ts` - Schema.org markup
  - `sitemap.ts` - Sitemap generation

- **`wordpress/` (1 file)** - WordPress integration
  - `client.ts` - WP REST API client

#### **Utilities:**
- **`utils/` (5 files)** - Helper functions
  - `date.ts` - Date formatting
  - `string.ts` - String manipulation
  - `array.ts` - Array utilities
  - `object.ts` - Object helpers
  - `async.ts` - Async utilities

- **`utils.ts`** (169 bytes) - Common utilities export

#### **Core Files:**
- **`godMode.ts`** (7.8KB) - **⭐ CORE** - God Mode API client
  - SQL execution
  - Relationship queries
  - Pool stats
  - Health checks

- **`react-query.ts`** (237 bytes) - TanStack Query setup

- **`schemas.ts`** (11KB) - **⭐ IMPORTANT** - Directus schema definitions
  - All collection types
  - Relation definitions
  - Field schemas

#### **Other Subsystems:**
- **`collections/` (1 file)** - Collection utilities
- **`data/` (1 file)** - Data transformations
- **`system/` (1 file)** - System utilities
- **`testing/` (1 file)** - Test helpers
- **`theme/` (1 file)** - Theme configuration
- **`validation/` (1 file)** - Validation schemas

### **Key Files to Know:**
1. **`godMode.ts`** - Your God Mode API wrapper
2. **`schemas.ts`** - Schema definitions (keep in sync with DB)
3. **`db.ts`** - Database connection
4. **`directus/client.ts`** - Directus SDK

---

## 📄 **2. `src/content/` - Astro Content Collections** (2 subdirs)

**Purpose:** Astro 5 Content Layer - blog posts, docs, and content sources

### **📂 Structure:**

```
src/content/
├── blog/           (1 file)
│   └── welcome.md  # Example blog post
└── docs/           (empty)
    # Documentation will go here
```

**Managed By:** `src/content.config.ts`

**Loaders:**
- **Glob Loader** - Scans `*.md` and `*.mdx` files
- **File Loader** - Loads JSON data (templates, campaigns)

**Usage:**
```typescript
import { getCollection } from 'astro:content';
const posts = await getCollection('blog');
```

**Status:** ✅ Ready for content (just created in Astro 5 upgrade)

---

## ⚙️ **3. `src/workers/` - Background Workers** (1 file)

**Purpose:** BullMQ workers for async content generation

### **📂 Structure:**

```
src/workers/
└── contentGenerator.ts  (7.8KB)
```

**`contentGenerator.ts`:**
- **Purpose:** Background job processor
- **Queue:** BullMQ (Redis-backed)
- **Jobs:**
  - Generate articles
  - Create pages
  - Process batches
  - Export content

**How It Works:**
```typescript
// Add job to queue
await contentQueue.add('generate-article', {
  template: 'blog-post',
  data: { title, content }
});

// Worker processes in background
worker.process('generate-article', async (job) => {
  const article = await generateArticle(job.data);
  return article;
});
```

**Run Worker:**
```bash
npm run worker
# Or: REDIS_HOST=localhost npx tsx src/workers/contentGenerator.ts
```

**Status:** ✅ Functional, requires Redis

---

## 🏷️ **4. `src/types/` - TypeScript Type Definitions** (1 file)

**Purpose:** Shared TypeScript types and interfaces

### **📂 Structure:**

```
src/types/
└── cartesian.ts  (3KB)
```

**`cartesian.ts`:**
```typescript
// Content generation types
export interface CartesianPattern {
  id: string;
  name: string;
  template: string;
  variables: Variable[];
}

export interface GenerationJob {
  id: string;
  status: 'pending' | 'processing' | 'completed';
  pattern: CartesianPattern;
  output: GeneratedContent[];
}

// 30+ more type definitions
```

**Used By:**
- Cartesian generator
- Factory components
- Job manager
- Content assembler

**Status:** ✅ Single source of truth for generation types

---

## 🎨 **5. `src/components/` - React/Astro Components** (14 subdirs, 200+ components)

**Purpose:** UI components for admin dashboard and frontend

### **📂 Major Sections:**

#### **`admin/` (118 components)** - **⭐ LARGEST**
**Purpose:** All admin dashboard UI

**Breakdown:**
- **Control Panels:**
  - `FactoryHandshake.tsx` - Python Bridge status
  - `ResourceMonitor.tsx` - System metrics
  - `SystemControl.tsx` - Master controls
  - `AwakenProtocol.tsx` - Master dashboard (NEW!)

- **Data Tables:**
  - `CollectionTable.tsx` - Generic data table
  - `ArticlesManager.tsx` - Articles CRUD
  - `PagesManager.tsx` - Pages manager
  - `SitesManager.tsx` - Multi-site config

- **Specialized:**
  - `ImageTemplateEditor.tsx` - Image generation
  - `CampaignManager.tsx` - Campaign control
  - `LocationBrowser.tsx` - Geo targeting
  - `DomainSetupGuide.tsx` - Domain config

- **Common:**
  - `Common/FeatureControl.tsx` - Feature toggles
  - `Common/HeaderStatus.tsx` - Header indicators
  - `Common/MasterReset.tsx` - System reset

- **HUD:**
  - `HUD/GlobalHUD.astro` - Dropdown menu
  - Uses `HUDItems.json` for menu structure

#### **Other Component Groups:**

**`analytics/` (4 components)** - Charts, metrics, dashboards

**`assembler/` (8 components)** - Content assembly UI
- Pipeline visualizer
- Workflow builder
- Quality checker

**`factory/` (9 components)** - Content factory UI
- Article cards
- Bulk actions
- Kanban board
- Options modal

**`intelligence/` (7 components)** - AI/avatar management
- Avatar cards
- Edit modals
- Metrics dashboards

**`blocks/` (25 components)** - Page builder blocks
- Hero blocks
- CTA blocks
- Content blocks
- Layout blocks

**`ui/` (18 components)** - **⭐ shadcn/ui components**
- `button.tsx`
- `dialog.tsx`
- `dropdown-menu.tsx`
- `select.tsx`
- `tabs.tsx`
- `toast.tsx`
- etc.

**Other:**
- `automations/` (1) - Workflow automation
- `collections/` (1) - Collection utilities
- `debug/` (1) - Debug tools
- `engine/` (4) - Core engine components
- `providers/` (1) - Context providers
- `system/` (empty) - System components
- `testing/` (7) - Test components

### **Component Architecture:**

```
Components
├── Astro Components (.astro)
│   └── Server-rendered, no JS
├── React Client Components (.tsx)
│   └── Client-side interactivity
└── React Server Components (.tsx)
    └── Server Islands (NEW in Astro 5)
```

**Total:** ~200+ components

---

## ⚡ **6. `src/actions/` - Astro Actions** (1 file) **NEW!**

**Purpose:** Type-safe backend logic (Astro 5 feature)

### **📂 Structure:**

```
src/actions/
└── index.ts  (8.2KB)
```

**`index.ts`:**
```typescript
export const server = {
  likePost,        // Like a post (Astro DB)
  addComment,      // Add comment (Astro DB)
  executeSql,      // Run SQL (PostgreSQL)
  getDatabaseStats, // Get DB metrics
  generateContent, // Factory generation
  createBackup,    // Database backup
};
```

**Usage:**
```typescript
// Client-side (type-safe!)
import { actions } from 'astro:actions';

const { data, error } = await actions.executeSql({
  sql: 'SELECT * FROM sites'
});
```

**Status:** ✅ Just created (Astro 5 upgrade)

**Integration Points:**
- SQL Console
- Factory UI
- Comment system
- Analytics dashboard

---

## 🛠️ **7. `scripts/` - Utility Scripts** (5 files)

**Purpose:** Setup, testing, and automation scripts

### **📂 Files:**

#### **`awaken-directus.sh`** (2.8KB)
- **Purpose:** Initialize Directus schema
- **What it does:**
  - Applies SQL migrations
  - Creates collections
  - Sets up relations
  - Configures interfaces

**Usage:**
```bash
./scripts/awaken-directus.sh
```

#### **`db-tunnel.sh`** (2.7KB) **⭐ IMPORTANT**
- **Purpose:** SSH tunnel to production database
- **What it does:**
  - Creates SSH tunnel via Coolify server
  - Maps `localhost:5433` → `10.0.1.10:5432`
  - Enables local dev access to prod DB

**Usage:**
```bash
./scripts/db-tunnel.sh
# Now DATABASE_URL=localhost:5433 works locally
```

#### **`god-mode.js`** (10.9KB) **⭐ CORE**
- **Purpose:** God Mode CLI tool
- **Features:**
  - Deploy campaigns
  - Execute SQL
  - Manage database
  - Test connections
  - Backup/restore

**Usage:**
```bash
node scripts/god-mode.js <command>
# Commands: deploy, sql, backup, test, etc.
```

#### **`start-worker.js`** (422 bytes)
- **Purpose:** Start BullMQ content worker
- **What it does:**
  - Loads environment
  - Connects to Redis
  - Starts worker process

**Usage:**
```bash
node scripts/start-worker.js
```

#### **`test-campaign.js`** (2KB)
- **Purpose:** Test campaign deployment
- **What it does:**
  - Loads sample campaign JSON
  - Posts to `/api/god/deploy`
  - Validates response

**Usage:**
```bash
npm run test:campaign
```

### **Scripts Summary:**

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `awaken-directus.sh` | Initialize Directus | First setup |
| `db-tunnel.sh` | Connect to prod DB | Local development |
| `god-mode.js` | CLI tool | Automation |
| `start-worker.js` | Start worker | Background jobs |
| `test-campaign.js` | Test deployment | Testing |

---

## 📦 **8. `dist/` - Build Output** (Production code)

**Purpose:** Compiled production code (generated by `npm run build`)

### **📂 Structure:**

```
dist/
├── client/     # Client-side JavaScript bundles
│   ├── chunks/ # Code-split chunks
│   ├── assets/ # CSS, images, fonts
│   └── entry.*.js # Entry points
│
└── server/     # Server-side code
    ├── chunks/ # SSR code chunks
    ├── entry.mjs # Main SSR entry
    └── manifest.json # Build manifest
```

**Generated By:** `astro build`

**Contents:**
- Optimized JS bundles
- Minified CSS
- Compressed images
- SSR server code
- Source maps (if enabled)

**Size:** Typically 5-15MB

**Deploy:** The `dist/` folder is what runs in production

**Git Status:** ⚠️ Should be in `.gitignore` (rebuilds on each deploy)

**Important Files:**
- `dist/server/entry.mjs` - Main SSR entry (run with `node ./dist/server/entry.mjs`)
- `dist/client/_astro/` - Static assets with hashed filenames

---

## 📊 **Folder Hierarchy Summary**

```
god-mode/
├── src/
│   ├── lib/          ⭐ CORE - All shared logic
│   ├── components/   🎨 UI - 200+ components
│   ├── actions/      ⚡ NEW - Type-safe backend
│   ├── content/      📄 NEW - Content collections
│   ├── workers/      ⚙️ Background jobs
│   └── types/        🏷️ TypeScript definitions
│
├── scripts/          🛠️ Utility scripts (5 files)
├── dist/             📦 Build output (auto-generated)
│
└── god_architect_local/  🐍 Python Bridge (4 scripts)
```

---

## 🎯 **Quick Reference**

### **Need to...**

**Add a new API endpoint?**
→ `src/actions/index.ts` (Astro Actions)
→ Or `src/pages/api/` (manual endpoints)

**Create a new component?**
→ `src/components/admin/` (admin UI)
→ `src/components/ui/` (reusable UI)

**Add shared logic?**
→ `src/lib/utils/`

**Define types?**
→ `src/types/`

**Add content?**
→ `src/content/blog/` or `src/content/docs/`

**Create background job?**
→ `src/workers/contentGenerator.ts`

**Add a script?**
→ `scripts/`

**Deploy?**
→ Build creates `dist/`, deploy `dist/`

---

## 📈 **Folder Stats**

| Folder | Subdirs | Files | Lines of Code | Purpose |
|--------|---------|-------|---------------|---------|
| `src/lib/` | 19 | 50+ | ~15,000 | Core logic |
| `src/components/` | 14 | 200+ | ~25,000 | UI components |
| `src/actions/` | 0 | 1 | ~250 | Backend actions |
| `src/content/` | 2 | 1 | ~50 | Content |
| `src/workers/` | 0 | 1 | ~300 | Workers |
| `src/types/` | 0 | 1 | ~100 | Types |
| `scripts/` | 0 | 5 | ~500 | Utilities |
| `dist/` | 2 | 100+ | N/A | Build output |

**Total Source Code:** ~40,000+ lines

---

**Your God Mode codebase is a well-organized powerhouse! Each folder has a clear purpose and defined responsibility.** 🔱
