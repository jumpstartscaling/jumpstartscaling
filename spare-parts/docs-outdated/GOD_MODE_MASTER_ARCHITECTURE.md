# 🔱 God Mode - Master Architecture

> **Last Updated:** December 21, 2025 01:30 EST
> **Status:** Production Ready + CDN Enhanced
> **System:** Hybrid Astro (SSR) + React + Python Bridge + JavaScript SDK

## 1. System Overview

God Mode is a "parasitic" administrative layer that sits on top of the Spark infrastructure. It allows for absolute control over all databases, content generation, and system operations without being constrained by the primary application logic.

### **Core Stack**
- **Frontend/Router:** Astro 5.0 (SSR Mode `output: 'server'`)
- **Interactive UI:** React 19.0 (Islands Architecture) + **CDN Fallback**
- **JavaScript SDK:** **NEW** - Universal client (`/js/god-mode-sdk.js`)
- **Styling:** Tailwind CSS + Shadcn UI
- **Backend/API:** Astro API Routes (Node.js runtime)
- **Intelligence:** Python Bridge (Streamlit + FastAPIs)
- **Data Layer:** PostgreSQL (Direct access) + Redis
- **State Management:** React Query (TanStack Query v5) + **CDN Support**
- **CDN Libraries:** React 19, TanStack Query v5, Axios, Day.js (unpkg.com)

---

## 2. Directory Structure

```
src/
├── components/         # React Components (Interactive Islands)
│   ├── admin/          # Admin-specific components
│   ├── providers/      # Context Providers (Core, Query)
│   └── ui/             # Shadcn UI primitives
├── layouts/            # Astro Layouts
│   └── AdminLayout.astro # Main Admin Shell
├── lib/                # Shared Utilities
│   ├── db/             # Database connections
│   ├── react-query/    # Query Client configuration
│   └── utils/          # Helper functions
├── pages/              # File-based Routing
│   ├── admin/          # Admin UI Pages
│   └── api/            # Server-Side API Routes
└── actions/            # Astro Actions (Server Functions)
```

---

## 3. Server-Side Rendering (SSR) & API

God Mode runs in **SSR Mode**, enabling dynamic, server-side functionality.

### **Configuration**
```javascript
// astro.config.mjs
export default defineConfig({
  output: 'server',
  adapter: node({
    mode: 'standalone'
  })
});
```

### **API Architecture**
- **RESTful Endpoints:** Located in `src/pages/api/*`
- **Dynamic Routing:** Supports `[id].ts` and `[...path].ts`
- **Authentication:** `X-God-Token` header validation
- **Database Access:** Direct `pg` pool connections

**Key Endpoints:**
- `/api/god/sql`: Execute raw SQL queries
- `/api/god/campaigns/create`: Launch content campaigns
- `/api/python/*`: Proxy to Python Intelligence Service

---

## 4. Frontend Architecture (React Islands)

God Mode uses Astro's Island Architecture to hydrate interactive React components only where needed.

### **Integration Pattern**
1. **Layout Level:** `AdminLayout.astro` wraps content in `CoreProvider`.
2. **Page Level:** Astro pages (`.astro`) fetch initial server data.
3. **Component Level:** React components (`.tsx`) use `client:only="react"`.

**Critical Rule:** All React components that use `useQuery` or `useMutation` MUST be mounted with `client:only="react"` to ensure they share the global `QueryClient` context.

```astro
<!-- Correct Usage -->
<LeadsManager client:only="react" />

<!-- Incorrect Usage (Causes Context Errors) -->
<LeadsManager client:load /> 
```

### **State Management**
- **React Query:** Handles server state, caching, and background updates.
- **Global Provider:** `CoreProvider` in `AdminLayout` initializes `QueryClient`.

---

## 5. Python Bridge Integration

The Python Bridge connects the Node.js/Astro frontend to Python-based AI services.

- **Location:** `god_architect_local/`
- **Communication:** HTTP Proxy via `/api/python/*`
- **Execution:** Spawns Python sub-processes for heavy AI tasks.

---

## 6. Deployment & Security

- **Environment:** Docker (Coolify)
- **Security:**
  - `GOD_MODE_TOKEN`: Required for all sensitive operations.
  - Server-only environment variables via `astro:env`.
  - CORS protection for API routes.

---

## 7. Current Status & Roadmap

### **Completed ✅**
- [x] Migration to Astro 5 & React 19
- [x] SSR Mode enabled globally
- [x] API Routes for SQL & Campaigns
- [x] Component Library (Shadcn UI)
- [x] React Query Fixes (Global Context)

### **In Progress 🚧**
- [ ] Tailwind v4 Migration
- [ ] WebSocket Real-time updates
- [ ] Enhanced vector search capabilities

---

**God Mode is designed for power users. Handle with care.** 🔱
