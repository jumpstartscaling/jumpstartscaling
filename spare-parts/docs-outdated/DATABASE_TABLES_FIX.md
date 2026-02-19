# 🗄️ DATABASE TABLES FIX - Complete Solution

## ✅ Progress So Far

1. ✅ SSL is working
2. ✅ Domain routing is fixed
3. ✅ Site is accessible at https://cms.jumpstartscaling.com
4. ✅ Database connection is configured
5. ❌ **Database tables don't exist yet**

---

## 🎯 The Issue

```
error: relation "users" does not exist
```

Your Payload CMS is trying to query the `users` table, but it hasn't been created yet.

**Database Connection:** ✅ Working
```
postgres://postgres:***@ok4gk4kc4kk0w4wgsksskswg:5432/postgres
```

**Problem:** The Payload config doesn't have auto-migration enabled.

---

## 🔧 THE FIX - Enable Auto-Push

We need to update the Payload configuration to automatically create tables on startup.

### Current Config (in container):
```typescript
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URI || '',
  },
}),
```

### What It Should Be:
```typescript
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URI || '',
  },
  push: true, // ← Add this line
}),
```

---

## 📝 How to Fix

### Option 1: Update Source Code & Redeploy (Recommended)

**If you have the source code locally or in GitHub:**

1. **Find the file:** `src/payload.config.ts`

2. **Update the database adapter:**
   ```typescript
   db: postgresAdapter({
     pool: {
       connectionString: process.env.DATABASE_URI || '',
     },
     push: true, // Auto-create tables in production
   }),
   ```

3. **Commit and push to GitHub** (if using GitHub deployment)
   ```bash
   git add src/payload.config.ts
   git commit -m "Enable auto-push for database tables"
   git push
   ```

4. **Redeploy in Coolify:**
   - Go to Coolify UI
   - Find your Payload CMS application
   - Click "Redeploy" or "Deploy Latest"
   - Wait for deployment to complete

5. **Visit:** https://cms.jumpstartscaling.com
   - Tables will be created automatically on startup
   - You'll see the Payload CMS setup wizard! ✅

### Option 2: Manual Table Creation (Quick Fix)

If you can't redeploy right now, you can manually create the tables:

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Connect to PostgreSQL
docker exec -it ok4gk4kc4kk0w4wgsksskswg psql -U postgres

# You're now in PostgreSQL shell
# Create the basic tables Payload needs:
```

```sql
-- Create users table
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

-- Create users_roles table
CREATE TABLE IF NOT EXISTS users_roles (
  id SERIAL PRIMARY KEY,
  parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  value VARCHAR(50),
  "order" INTEGER
);

-- Create users_sessions table
CREATE TABLE IF NOT EXISTS users_sessions (
  id SERIAL PRIMARY KEY,
  _parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  _order INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP
);

-- Create tenants table
CREATE TABLE IF NOT EXISTS tenants (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create pages table
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

-- Create media table
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON tenants(slug);
CREATE INDEX IF NOT EXISTS idx_pages_slug ON pages(slug);
CREATE INDEX IF NOT EXISTS idx_pages_tenant ON pages(tenant_id);

-- Exit PostgreSQL
\q
```

Then restart the Payload container:
```bash
docker restart ksgwgg0kg08o000s80wcgkks-191538437129
```

### Option 3: Use Coolify Environment Variable

Add an environment variable to enable push mode:

1. **Go to Coolify UI**
2. **Find your Payload CMS application**
3. **Go to "Environment Variables"**
4. **Add:**
   - Name: `PAYLOAD_AUTO_PUSH`
   - Value: `true`
5. **Save and Restart**

Then update your `src/payload.config.ts` to use it:
```typescript
db: postgresAdapter({
  pool: {
    connectionString: process.env.DATABASE_URI || '',
  },
  push: process.env.PAYLOAD_AUTO_PUSH === 'true',
}),
```

---

## 🚀 Recommended Approach

**I recommend Option 1** (Update source code & redeploy) because:
- ✅ Clean and permanent solution
- ✅ Tables will be auto-created on every deployment
- ✅ Schema changes will be auto-applied
- ✅ No manual SQL needed

---

## ✅ After Tables Are Created

1. **Visit:** https://cms.jumpstartscaling.com
2. **You'll see:** Payload CMS initial setup wizard
3. **Create your first admin user:**
   - Email: your@email.com
   - Password: (strong password)
4. **Create your first tenant**
5. **Start managing content!** 🎉

---

## 🔍 Verify Tables Were Created

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Connect to database
docker exec -it ok4gk4kc4kk0w4wgsksskswg psql -U postgres

# List all tables
\dt

# Should see:
# users
# users_roles
# users_sessions
# tenants
# pages
# media
# payload_migrations
# payload_preferences
```

---

## 📋 Checklist

- [ ] Update `src/payload.config.ts` to add `push: true`
- [ ] Commit and push changes (if using Git)
- [ ] Redeploy in Coolify
- [ ] Wait for deployment to complete
- [ ] Visit https://cms.jumpstartscaling.com
- [ ] See Payload CMS setup wizard (no more database errors!)
- [ ] Create admin user
- [ ] Create first tenant
- [ ] Start using CMS! ✅

---

## 🆘 Need Help?

If you don't have access to the source code, let me know and I can:
1. Help you find the GitHub repository
2. Clone it locally
3. Make the changes
4. Push and redeploy

---

**The fix is simple: just add `push: true` to the database adapter config! 🚀**
