# 🎯 IMMEDIATE ACTION REQUIRED

## ✅ What's Working Now

1. ✅ **SSL is working** - The domain fix worked!
2. ✅ **Site is accessible** - https://cms.jumpstartscaling.com loads
3. ✅ **Database is connected** - PostgreSQL connection is configured
4. ❌ **Database tables don't exist** - Need to create them

---

## 🚨 THE ISSUE

```
error: relation "users" does not exist
```

Your Payload CMS needs database tables, but they haven't been created yet.

---

## 🔧 QUICK FIX (Choose One)

### Option 1: Manual SQL (5 minutes - Works Immediately)

Run these commands to create the tables manually:

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Connect to PostgreSQL
docker exec -it ok4gk4kc4kk0w4wgsksskswg psql -U postgres

# Copy and paste this entire SQL block:
```

```sql
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  tenant_id INTEGER,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  email VARCHAR(255) UNIQUE NOT NULL,
  reset_password_token VARCHAR(255),
  reset_password_expiration TIMESTAMP,
  salt VARCHAR(255),
  hash VARCHAR(255),
  login_attempts INTEGER DEFAULT 0,
  lock_until TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users_roles (
  id SERIAL PRIMARY KEY,
  parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  value VARCHAR(50),
  "order" INTEGER
);

CREATE TABLE IF NOT EXISTS users_sessions (
  id SERIAL PRIMARY KEY,
  _parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  _order INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tenants (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS pages (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255),
  slug VARCHAR(255),
  tenant_id INTEGER REFERENCES tenants(id),
  content JSONB,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  published BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS media (
  id SERIAL PRIMARY KEY,
  filename VARCHAR(255),
  mime_type VARCHAR(100),
  filesize INTEGER,
  width INTEGER,
  height INTEGER,
  url VARCHAR(500),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payload_preferences (
  id SERIAL PRIMARY KEY,
  key VARCHAR(255),
  value JSONB,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payload_migrations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  batch INTEGER,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON tenants(slug);
CREATE INDEX IF NOT EXISTS idx_pages_slug ON pages(slug);
CREATE INDEX IF NOT EXISTS idx_pages_tenant ON pages(tenant_id);

-- Exit PostgreSQL
\q
```

Then restart the container:
```bash
docker restart ksgwgg0kg08o000s80wcgkks-191538437129
exit
```

**Then visit:** https://cms.jumpstartscaling.com ✅

---

### Option 2: Fix Source Code & Redeploy (Permanent Solution)

**Do you have access to the GitHub repository for this Payload CMS?**

If yes, I can help you:
1. Update `src/payload.config.ts` to add `push: true`
2. Commit and push the changes
3. Redeploy in Coolify
4. Tables will auto-create on startup

**Repository might be:** `https://github.com/jumpstartscaling/jumpstart-cms`

---

## ✅ After Tables Are Created

1. Visit: https://cms.jumpstartscaling.com
2. You'll see: Payload CMS setup wizard
3. Create your first admin user
4. Create your first tenant
5. Start managing content! 🎉

---

## 🎯 Recommendation

**Use Option 1 (Manual SQL)** right now to get it working immediately.

Then later, update the source code (Option 2) for a permanent fix.

---

**Which option do you want to use?**
- Option 1: Manual SQL (works now, 5 minutes)
- Option 2: Fix source code (permanent, need GitHub access)
