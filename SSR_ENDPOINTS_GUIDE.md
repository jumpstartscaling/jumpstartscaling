# 🔱 God Mode - SSR & Dynamic Endpoints Guide

## ✅ SSR Mode ENABLED

**Current Configuration:** `output: 'server'` in `astro.config.mjs`

This means **ALL pages and API routes** are server-side rendered by default, enabling:
- ✅ Full CRUD operations (GET, POST, PUT, PATCH, DELETE)
- ✅ Dynamic endpoints with authentication
- ✅ Protected environment variables
- ✅ Real-time data fetching
- ✅ Server Islands for deferred rendering

---

## 📁 Existing API Routes (All SSR-Enabled)

### **Current Endpoints:**

```
/api/god/
├── sql.ts              - Generic SQL execution
├── redeploy.ts         - Self-deployment/Update
├── health.ts           - System health check
├── pool/stats.ts       - Database pool statistics
├── relationships.ts    - Schema relationships
├── system/control.ts   - System controls
└── campaigns/
    ├── create.ts       - Create new campaign
    ├── launch/[id].ts  - Launch campaign
    └── status/[id].ts  - Check campaign status

/api/collections/
├── [collection].ts     - Dynamic collection access
└── [table].ts          - Dynamic table access

/api/python/
├── [...path].ts        - Python Bridge proxy
└── index.ts            - Python Bridge status

/api/system/
└── health.ts           - System health endpoint
```

---

## 🚀 How to Create Dynamic Endpoints

### **1. Static JSON Generation (Build Time)**

```typescript
// src/pages/api/products.json.ts
import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';

export const GET: APIRoute = async () => {
    const products = await getCollection('products', ({ data }) => {
        return data.inStock === true;
    });

    return new Response(JSON.stringify(products), {
        status: 200,
        headers: {
            'Content-Type': 'application/json'
        }
    });
};
```

**Access:** `http://localhost:4322/api/products.json`  
**Build:** Creates static `/api/products.json` file

---

### **2. Dynamic SSR Endpoints (Runtime)**

With `output: 'server'`, all API routes support ALL HTTP methods:

#### **GET Request**
```typescript
// src/pages/api/posts.json.ts
import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ request, url }) => {
    const searchParams = url.searchParams;
    const limit = searchParams.get('limit') || '10';
    
    // Fetch from database
    const posts = await db.query('SELECT * FROM posts LIMIT $1', [limit]);
    
    return new Response(JSON.stringify(posts), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
    });
};
```

#### **POST Request**
```typescript
export const POST: APIRoute = async ({ request }) => {
    const data = await request.json();
    
    // Validate and insert
    const result = await db.query(
        'INSERT INTO posts (title, content) VALUES ($1, $2) RETURNING *',
        [data.title, data.content]
    );
    
    return new Response(JSON.stringify(result.rows[0]), {
        status: 201,
        headers: { 'Content-Type': 'application/json' }
    });
};
```

#### **PUT/PATCH Request**
```typescript
export const PUT: APIRoute = async ({ request }) => {
    const data = await request.json();
    
    const result = await db.query(
        'UPDATE posts SET title = $1, content = $2 WHERE id = $3 RETURNING *',
        [data.title, data.content, data.id]
    );
    
    return new Response(JSON.stringify(result.rows[0]), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
    });
};
```

#### **DELETE Request**
```typescript
export const DELETE: APIRoute = async ({request, url }) => {
    const id = url.searchParams.get('id');
    
    await db.query('DELETE FROM posts WHERE id = $1', [id]);
    
    return new Response(JSON.stringify({ success: true }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
    });
};
```

---

### **3. Dynamic Routing with Parameters**

```typescript
// src/pages/api/posts/[id].json.ts
import type { APIRoute } from 'astro';

export const GET: APIRoute = async ({ params }) => {
    const { id } = params;
    
    const post = await db.query('SELECT * FROM posts WHERE id = $1', [id]);
    
    if (post.rows.length === 0) {
        return new Response(JSON.stringify({ error: 'Post not found' }), {
            status: 404,
            headers: { 'Content-Type': 'application/json' }
        });
    }
    
    return new Response(JSON.stringify(post.rows[0]), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
    });
};

export const DELETE: APIRoute = async ({ params }) => {
    const { id } = params;
    
    await db.query('DELETE FROM posts WHERE id = $1', [id]);
    
    return new Response(JSON.stringify({ success: true, id }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
    });
};
```

**Access:**
- `GET /api/posts/123.json` - Get post 123
- `DELETE /api/posts/123.json` - Delete post 123

---

### **4. Protected Endpoints with Auth**

```typescript
// src/pages/api/admin/sites.json.ts
import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
    // Check God Mode token
    const token = request.headers.get('X-God-Token');
    
    if (token !== import.meta.env.GOD_MODE_TOKEN) {
        return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { 'Content-Type': 'application/json' }
        });
    }
    
    const data = await request.json();
    
    // Create site in database
    const result = await db.query(
        'INSERT INTO sites (domain, name) VALUES ($1, $2) RETURNING *',
        [data.domain, data.name]
    );
    
    return new Response(JSON.stringify(result.rows[0]), {
        status: 201,
        headers: { 'Content-Type': 'application/json' }
    });
};
```

#### **Environment Variables (Server-Only)**

```javascript
// astro.config.mjs
export default defineConfig({
    env: {
        schema: {
            // Server-only (safe)
            GOD_MODE_TOKEN: envField.string({
                context: 'server',
                access: 'secret',
            }),
            DATABASE_URL: envField.string({
                context: 'server',
                access: 'secret',
            }),
            
            // Client-accessible (public)
            PUBLIC_SITE_URL: envField.string({
                context: 'client',
                access: 'public',
                default: 'http://localhost:4322'
            }),
        }
    }
});
```

---

## 🎯 God Mode Specific Examples

### **Execute SQL via API**

```typescript
// Already exists at: src/pages/api/god/sql.ts
import type { APIRoute } from 'astro';
import { executeQuery } from '@/lib/database';

export const POST: APIRoute = async ({ request }) => {
    // ... authentication and logic ...
};
```

### **Frontend Usage (React/Astro)**

```typescript
// From any React component or Astro script
const executeSql = async (sql: string) => {
    const response = await fetch('/api/god/sql', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-God-Token': import.meta.env.GOD_MODE_TOKEN
        },
        body: JSON.stringify({ query: sql }) // Note: uses 'query' or 'sql' param
    });
    
    const data = await response.json();
    return data.rows;
};

// Usage
const sites = await executeSql('SELECT * FROM sites LIMIT 10');
```

---

## 📊 Existing God Mode Endpoints

### **1. Campaign Deployment**
```bash
POST /api/god/campaigns/create
Headers: X-God-Token: <token>
Body: { name, blueprint }
```

### **2. Health Check**
```bash
GET /api/god/health
GET /api/system/health
```

### **3. Database Pool Stats**
```bash
GET /api/god/pool/stats
Headers: X-God-Token: <token>
```

### **4. Python Bridge Proxy**
```bash
GET/POST /api/python/api/*
Headers: X-God-Token: <token>
```

### **5. Collection Access**
```bash
GET /api/collections/[collection]
POST /api/collections/[collection]
DELETE /api/collections/[collection]
```

---

## 🔒 Security Best Practices

### **1. Always Validate Tokens**
```typescript
const validateToken = (request: Request): boolean => {
    const token = request.headers.get('X-God-Token');
    return token === import.meta.env.GOD_MODE_TOKEN;
};
```

### **2. Use CORS Headers**
```typescript
const corsHeaders = {
    'Access-Control-Allow-Origin': import.meta.env.PUBLIC_SITE_URL,
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
    'Access-Control-Allow-Headers': 'Content-Type, X-God-Token',
};
```

### **3. Rate Limiting**
```typescript
// Use Astro middleware for rate limiting
// src/middleware/index.ts
export const onRequest = async ({ request }, next) => {
    // Implement rate limiting logic
    return next();
};
```

---

## 🧪 Testing Endpoints

### **Using cURL**
```bash
# GET
curl http://localhost:4322/api/posts.json

# POST
curl -X POST http://localhost:4322/api/posts.json \
  -H "Content-Type: application/json" \
  -H "X-God-Token: your-token" \
  -d '{"title":"New Post","content":"Content here"}'

# DELETE
curl -X DELETE http://localhost:4322/api/posts/123.json \
  -H "X-God-Token: your-token"
```

### **Using Thunder Client / Postman**
1. Create new request
2. Set method (GET, POST, etc.)
3. Add headers: `X-God-Token`, `Content-Type`
4. Add body (for POST/PUT)
5. Send request

---

## 🚀 Next Steps

1. **✅ SSR Already Enabled** - `output: 'server'` in config
2. **✅ QueryProvider Added** - All React Query components work
3. **✅ Dynamic Endpoints Active** - All HTTP methods available
4. **⚡ Create More Endpoints** - Add as needed in `/src/pages/api/`

---

**All God Mode API routes support full CRUD operations!** 🔱
