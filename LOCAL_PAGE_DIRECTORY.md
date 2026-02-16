# 🔱 God Mode - Local Development Page Directory

**Dev Server:** http://localhost:4322  
**Status:** ✅ Running (Port 4322)  
**Last Updated:** 2025-12-20

---

## 🎯 **MAIN DASHBOARDS**

### **Master Control Center**
**[Awaken Protocol](http://localhost:4322/admin/awaken)** - NEW!  
The ultimate master dashboard with all system status, page directory, and controls

**[Mission Control](http://localhost:4322/admin)**  
Primary admin dashboard

---

## 📊 **ANALYTICS & MONITORING**

**[System Status](http://localhost:4322/admin/status)**  
Real-time system health monitoring

**[Analytics Dashboard](http://localhost:4322/admin/analytics)**  
Traffic and performance metrics

**[Performance Analytics](http://localhost:4322/admin/analytics/performance)**  
Web Vitals and speed metrics

**[Resource Monitor](http://localhost:4322/admin/resource-monitor)**  
CPU, RAM, and database metrics

---

## 🏭 **CONTENT FACTORY**

**[Content Factory Dashboard](http://localhost:4322/admin/factory)**  
Main content generation hub

**[Campaigns Manager](http://localhost:4322/admin/campaigns)**  
Campaign creation and management

**[Articles Manager](http://localhost:4322/admin/articles)**  
Article CRUD operations

**[Pages Manager](http://localhost:4322/admin/pages)**  
Page management

**[Bulk Generator](http://localhost:4322/admin/bulk-generate)**  
Mass content generation

---

## 🌐 **SITE MANAGEMENT**

**[Sites Dashboard](http://localhost:4322/admin/sites)**  
Multi-site configuration

**[Domain Setup](http://localhost:4322/admin/domain-setup)**  
Domain configuration guide

**[Site Editor](http://localhost:4322/admin/site-editor)**  
Visual site editor

---

## 🎨 **CONTENT TOOLS**

**[Template Editor](http://localhost:4322/admin/templates)**  
Template creation and editing

**[Image Template Editor](http://localhost:4322/admin/image-templates)**  
Featured image generation

**[Block Editor](http://localhost:4322/admin/blocks)**  
Content block builder

**[Page Builder](http://localhost:4322/admin/page-builder)**  
Visual page composer

---

## 🤖 **INTELLIGENCE & AUTOMATION**

**[AI Avatars](http://localhost:4322/admin/avatars)**  
Persona management

**[Intelligence Library](http://localhost:4322/admin/intelligence)**  
Knowledge base and AI tools

**[Workflow Builder](http://localhost:4322/admin/workflows)**  
Automation workflows

**[Job Queue](http://localhost:4322/admin/jobs)**  
Background job monitoring

---

## 📍 **LOCATION & SEO**

**[Location Browser](http://localhost:4322/admin/locations)**  
Geographic targeting

**[County Matrix](http://localhost:4322/admin/locations/counties)**  
County-level data

**[Cartesian Generator](http://localhost:4322/admin/cartesian)**  
Pattern-based content generation

**[SEO Manager](http://localhost:4322/admin/seo)**  
SEO optimization tools

---

## 🗄️ **DATABASE & API**

**[SQL Terminal](http://localhost:4322/admin/terminal)**  
Direct SQL execution

**[Database Mechanic](http://localhost:4322/admin/mechanic)**  
Database maintenance

**[API Explorer](http://localhost:4322/admin/api-explorer)**  
API testing interface

**[Relationship Explorer](http://localhost:4322/admin/relationships)**  
Database schema visualizer

---

## 🎛️ **SYSTEM CONTROLS**

**[System Control](http://localhost:4322/admin/system-control)**  
Master system toggles

**[Factory Handshake](http://localhost:4322/admin/factory-handshake)**  
Python Bridge status

**[Configuration](http://localhost:4322/admin/config)**  
System settings

**[Environment Variables](http://localhost:4322/admin/env)**  
Environment config

---

## 🧪 **TESTING & DEBUGGING**

**[Component Showcase](http://localhost:4322/admin/showcase)**  
UI component library

**[Testing Dashboard](http://localhost:4322/admin/testing)**  
Test suite interface

**[Debug Console](http://localhost:4322/admin/debug)**  
Debug tools

**[Logs Viewer](http://localhost:4322/admin/logs)**  
System logs

---

## 📦 **CONTENT COLLECTIONS**

**[Collections Browser](http://localhost:4322/admin/collections)**  
Directus collections

**[Media Library](http://localhost:4322/admin/media)**  
Asset management

**[Tags Manager](http://localhost:4322/admin/tags)**  
Tag taxonomy

**[Categories](http://localhost:4322/admin/categories)**  
Category management

---

## 🔐 **DIRECTUS INTEGRATION**

**[Directus Dashboard](http://localhost:4322/admin/directus)**  
Directus admin panel proxy

**[Directus Collections](http://localhost:4322/admin/directus/collections)**  
Collection management

**[Directus Users](http://localhost:4322/admin/directus/users)**  
User management

---

## 🐍 **PYTHON BRIDGE**

**[Python Bridge Status](http://localhost:4322/api/python/api/status)**  
FastAPI health check (JSON)

**[Python Config](http://localhost:4322/api/python/api/config)**  
Current system configuration (JSON)

**[Streamlit Dashboard](http://localhost:8501)**  
Visual Python control panel

---

## 🔧 **API ENDPOINTS** (JSON Responses)

### **God Mode API**
- **[Pool Stats](http://localhost:4322/api/god/pool/stats)** - Database pool status
- **[System Health](http://localhost:4322/api/system/health)** - System health check
- **[Relationships](http://localhost:4322/api/god/relationships)** - Schema relationships

### **Astro Actions** (Use via forms/fetch)
- `/actions/executeSql` - Execute SQL
- `/actions/getDatabaseStats` - Get DB stats
- `/actions/createBackup` - Create backup
- `/actions/generateContent` - Generate content

---

## 📱 **RESPONSIVE VIEWS**

All pages support:
- 📱 Mobile (320px+)
- 📱 Tablet (768px+)
- 💻 Desktop (1024px+)
- 🖥️ Large Desktop (1920px+)

---

## 🎯 **QUICK START TOUR**

**Recommended viewing order:**

1. **[Awaken Protocol](http://localhost:4322/admin/awaken)** - Start here!
2. **[Mission Control](http://localhost:4322/admin)** - Main dashboard
3. **[Content Factory](http://localhost:4322/admin/factory)** - Generate content
4. **[SQL Terminal](http://localhost:4322/admin/terminal)** - Execute queries
5. **[System Status](http://localhost:4322/admin/status)** - Monitor health

---

## 🔍 **SEARCH & FILTER**

**By Category:**
```
/admin/*           - All admin pages
/admin/analytics/* - Analytics pages
/admin/locations/* - Location pages
/api/god/*         - God Mode API
/api/python/*      - Python Bridge API
```

**By Function:**
- **Create Content:** Factory, Bulk Generator, Templates
- **Manage Sites:** Sites, Domain Setup, Site Editor
- **Monitor System:** Status, Analytics, Resource Monitor
- **Execute Tasks:** Terminal, API Explorer, Job Queue
- **Configure:** System Control, Configuration, Environment

---

## 🚀 **TESTING CHECKLIST**

Before deploying, test these key pages:

- [ ] **[Awaken Protocol](http://localhost:4322/admin/awaken)** - All services show online
- [ ] **[Factory](http://localhost:4322/admin/factory)** - Can generate content
- [ ] **[SQL Terminal](http://localhost:4322/admin/terminal)** - Queries execute
- [ ] **[Sites](http://localhost:4322/admin/sites)** - Sites load correctly
- [ ] **[Python Bridge](http://localhost:4322/api/python/api/status)** - Returns 200 OK
- [ ] **[Resource Monitor](http://localhost:4322/admin/resource-monitor)** - Charts render
- [ ] **[Analytics](http://localhost:4322/admin/analytics)** - Data displays

---

## 💡 **PRO TIPS**

**Fast Navigation:**
- Use the **Global HUD** dropdown (top-right) on any page
- Bookmark the **[Awaken Protocol](http://localhost:4322/admin/awaken)** as your home
- Use **CMD+Click** (Mac) or **CTRL+Click** (Windows) to open in new tabs

**Debug Mode:**
- Add `?debug=true` to any URL for verbose logging
- Check browser console (F12) for detailed errors
- Monitor Network tab for API calls

**Performance:**
- Pages with charts may be slower on first load
- Use **React DevTools** to inspect components
- Monitor **Astro Dev Toolbar** (bottom of page)

---

## 🎨 **THEME TOGGLE**

All pages support:
- 🌙 Dark Mode (default)
- ☀️ Light Mode (toggle in settings)
- 🎨 Custom themes (via CSS variables)

---

## 🔗 **EXTERNAL SERVICES**

**Production Directus:**
- [Directus Admin](https://office.jumpstartscaling.com/admin/)
- [Directus API](https://office.jumpstartscaling.com/items/)

**Production Database:**
- Access via SSH tunnel: `./scripts/db-tunnel.sh`
- Then connect to `localhost:5433`

**Streamlit Dashboard:**
- [God Architect UI](http://localhost:8501)
- Python-based visual controls

---

## 📊 **PAGE COUNT**

**Total Pages:** 70+  
**Admin Pages:** 60+  
**API Endpoints:** 10+  
**Status:** ✅ All functional

---

**Start exploring at: [http://localhost:4322/admin/awaken](http://localhost:4322/admin/awaken)** 🔱
