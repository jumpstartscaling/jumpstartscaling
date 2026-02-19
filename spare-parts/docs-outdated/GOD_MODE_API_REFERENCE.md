# 🔱 God Mode - API Reference

> **Base URL:** `/api/god`
> **Auth Header:** `X-God-Token: <your-secret-token>`
> **Content-Type:** `application/json`
> **JavaScript SDK:** `/js/god-mode-sdk.js` (Vanilla JS + CDN React)

## 🎯 JavaScript SDK (Recommended)

### **Quick Start**
```javascript
// SDK is auto-loaded on all admin pages
// Set your token if not already set
godMode.setToken('your-god-mode-token');

// Execute SQL
const result = await godMode.sql('SELECT * FROM sites LIMIT 10');
console.log(result);

// Get campaigns
const campaigns = await godMode.getCampaigns();

// Create campaign
const newCampaign = await godMode.createCampaign({
  name: 'Summer Campaign',
  niche_variables: { niche: 'solar panels' }
});

// Generate headlines
const headlines = await godMode.generateHeadlines('campaign-id', 1000);
```

### **Available Methods**

#### God Mode API
- `godMode.sql(query, params)` - Execute raw SQL
- `godMode.poolStats()` - Database connection statistics
- `godMode.dbStatus()` - Database health check
- `godMode.tables()` - List all database tables
- `godMode.tableSchema(tableName)` - Get table schema
- `godMode.relationships()` - Get table relationships
- `godMode.logs(limit)` - Get work logs
- `godMode.health()` - System health check
- `godMode.services()` - Service status
- `godMode.ingest(data)` - Ingest external data
- `godMode.mechanic(action)` - Run database maintenance

#### Directus API
- `godMode.getItems(collection, options)` - Get collection items
- `godMode.getItem(collection, id, fields)` - Get single item
- `godMode.createItem(collection, data)` - Create item
- `godMode.updateItem(collection, id, data)` - Update item
- `godMode.deleteItem(collection, id)` - Delete item
- `godMode.aggregate(collection, options)` - Aggregate data

#### Campaign API
- `godMode.getCampaigns(siteId)` - Get campaigns
- `godMode.createCampaign(data)` - Create campaign
- `godMode.generateHeadlines(campaignId, maxHeadlines)` - Generate headlines
- `godMode.generateArticles(campaignId, batchSize)` - Generate articles
- `godMode.publishArticle(articleId, wpSiteUrl)` - Publish to WordPress

#### Sites API
- `godMode.getSites()` - Get all sites
- `godMode.getSite(siteId)` - Get single site
- `godMode.createSite(data)` - Create site
- `godMode.updateSite(siteId, data)` - Update site

### **Example: Generate Campaign Content**
```javascript
// 1. Create campaign
const campaign = await godMode.createCampaign({
  name: 'Local Services Q1 2025',
  niche_variables: { 
    service: 'HVAC repair',
    tone: 'professional'
  },
  location_mode: 'city',
  headline_spintax_root: 'Best {service} in {city}, {state}'
});

// 2. Generate headlines
const headlineResult = await godMode.generateHeadlines(campaign.id, 5000);
console.log(`Generated ${headlineResult.inserted} headlines`);

// 3. Generate articles
const articleResult = await godMode.generateArticles(campaign.id, 100);
console.log(`Generated ${articleResult.generated} articles`);

// 4. Publish to WordPress
for (const article of articleResult.articles) {
  await godMode.publishArticle(article.id, 'https://example.com');
}
```

---

## 1. Core Endpoints

### **Execute SQL**
Execute raw SQL queries against the primary database. **Use with extreme caution.**

**Endpoint:** `POST /api/god/sql`

**Body:**
```json
{
  "query": "SELECT * FROM sites WHERE status = 'active' LIMIT 5"
}
```

**Response:**
```json
{
  "success": true,
  "rowCount": 5,
  "rows": [ ... ],
  "command": "SELECT"
}
```

---

### **System Health**
Check the operational status of God Mode services.

**Endpoint:** `GET /api/god/health`

**Response:**
```json
{
  "status": "healthy",
  "database": "connected",
  "redis": "connected",
  "python_bridge": "active",
  "uptime": 12345
}
```

---

## 2. Campaign Management

### **Create Campaign**
Deploy a new content generation campaign.

**Endpoint:** `POST /api/god/campaigns/create`

**Body:**
```json
{
  "name": "Summer Sale 2025",
  "blueprint": {
    "asset_name": "Summer Promo",
    "deployment_target": "all-sites",
    "content": { ... }
  }
}
```

### **Launch Campaign**
Trigger content generation for a specific campaign ID.

**Endpoint:** `POST /api/god/campaigns/launch/[id]`

---

## 3. Python Bridge

### **Message Proxy**
Send commands directly to the God Architect Python service.

**Endpoint:** `POST /api/python/api/chat`

**Body:**
```json
{
  "message": "Analyze system patterns",
  "context": { ... }
}
```

---

## 4. Collections API (Dynamic)

### **Get Collection Items**
Fetch items from any database table.

**Endpoint:** `GET /api/collections/[collection_name]`
**Query Params:** `?limit=10&sort=-created_at`

### **Create Item**
Insert new record into any table.

**Endpoint:** `POST /api/collections/[collection_name]`

---

## 5. Security & Error Handling

### **Authentication**
All requests MUST include the `X-God-Token` header.
- **401 Unauthorized:** Missing or invalid token.

### **Common Errors**
- **400 Bad Request:** Missing required body fields.
- **403 Forbidden:** Operation blocked (e.g., dangerous SQL).
- **500 Server Error:** Internal system failure.

### **Rate Limiting**
God Mode endpoints are rate-limited to 60 requests/minute to prevent abuse, though authorized admin IPs may have higher limits.

---

## 📚 Additional Resources

- **SDK Source:** `/public/js/god-mode-sdk.js`
- **CDN Integration Guide:** `/docs/CDN_INTEGRATION_PLAN.md`
- **System Health:** `/docs/SYSTEM_HEALTH_REPORT.md`
- **Master Architecture:** `/GOD_MODE_MASTER_ARCHITECTURE.md`

**Last Updated:** 2025-12-21 01:30 EST
