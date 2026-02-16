# 🗄️ DATABASE MIGRATION FIX

## ✅ Good News!

**The domain fix worked!** Your site is now accessible at https://cms.jumpstartscaling.com

The SSL and routing are working perfectly. Now we just need to create the database tables.

---

## 🎯 The Issue

```
error: relation "users" does not exist
```

**Translation:** The PostgreSQL database exists, but it's empty. Payload CMS needs to create its tables.

---

## 🔧 THE FIX - Run Migrations

### Option 1: Via Coolify UI (Easiest)

1. **Go to Coolify:** http://spark.jumpstartscaling.com:8000
2. **Find your Payload CMS application**
3. **Look for "Execute Command" or "Terminal" or "Console"**
4. **Run this command:**
   ```bash
   npm run payload migrate
   ```
   Or:
   ```bash
   pnpm payload migrate
   ```
   Or:
   ```bash
   yarn payload migrate
   ```

### Option 2: Via SSH (Direct)

SSH into the server and run the migration inside the container:

```bash
# SSH to server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Run migration in the Payload container
docker exec -it ksgwgg0kg08o000s80wcgkks-170052282299 npm run payload migrate

# Or if using pnpm
docker exec -it ksgwgg0kg08o000s80wcgkks-170052282299 pnpm payload migrate
```

### Option 3: Auto-migrate on Startup

Update your Payload configuration to auto-migrate on startup.

**Check if you have this in your `payload.config.ts`:**

```typescript
export default buildConfig({
  // ... other config
  db: postgresAdapter({
    pool: {
      connectionString: process.env.DATABASE_URI,
    },
    // Add this:
    migrationDir: './migrations',
    push: process.env.NODE_ENV === 'production', // Auto-push in production
  }),
})
```

Then restart the application in Coolify.

---

## 🚀 Quick Command to Run

Let me run the migration for you:

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 \
  'docker exec ksgwgg0kg08o000s80wcgkks-170052282299 npm run payload migrate'
```

---

## ✅ Expected Output

After running the migration, you should see:

```
✓ Migrating users collection
✓ Migrating tenants collection
✓ Migrating pages collection
✓ Creating indexes
✓ Migration complete
```

---

## 🎯 After Migration

1. **Refresh the page:** https://cms.jumpstartscaling.com
2. **You should see:** Payload CMS setup wizard
3. **Create your first admin user:**
   - Email: your@email.com
   - Password: (strong password)
4. **Create your first tenant**
5. **Start managing content!** 🎉

---

## 🆘 If Migration Fails

### Check Database Connection

```bash
# Check if DATABASE_URI is set
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 \
  'docker exec ksgwgg0kg08o000s80wcgkks-170052282299 env | grep DATABASE'
```

### Check Database is Running

```bash
# Check PostgreSQL container
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 \
  'docker ps | grep postgres'
```

### Manual Table Creation

If migrations don't work, you can manually create tables:

```bash
# Connect to PostgreSQL
ssh -i ~/.ssh/id_rsa opc@193.122.168.215

# Find the database container name
docker ps | grep postgres

# Connect to database (replace container name)
docker exec -it ok4gk4kc4kk0w4wgsksskswg psql -U postgres

# List databases
\l

# Connect to your Payload database
\c your_database_name

# Check if tables exist
\dt

# Exit
\q
```

---

## 📋 Checklist

- [ ] Run migration command
- [ ] Wait for migration to complete
- [ ] Refresh https://cms.jumpstartscaling.com
- [ ] See Payload CMS setup wizard
- [ ] Create admin user
- [ ] Create first tenant
- [ ] Start using CMS! ✅

---

**Let's run the migration now!** 🚀
