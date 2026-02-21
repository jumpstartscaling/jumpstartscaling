# DIRECTUS CONNECTION - QUICK FIX

## The Problem
Your Directus is trying to connect to hostname "host" (the placeholder) instead of your actual database.

## The Solution

### Step 1: Get God Mode's Database URL

1. In Coolify, go to your **God Mode deployment**
2. Click **Environment Variables**
3. Find `DATABASE_URL`
4. **Copy the entire value** (looks like: `postgresql://user:pass@host:5432/dbname`)

### Step 2: Update Directus Environment Variables

In Directus deployment, **replace** `GOD_MODE_DATABASE_URL` with the value you copied:

```bash
GOD_MODE_DATABASE_URL=postgresql://actual_user:actual_password@actual_host:5432/actual_database
```

### Step 3: Restart Directus

After updating the variable, restart the Directus deployment.

## Expected Result

Directus logs should show:
```
✅ Database connection established
✅ Redis connection established  
✅ Server initialized
✅ Ready to accept connections
```

## If Still Not Working

The database URL format must be EXACT. Check for:
- No extra spaces
- No quotes around the URL
- Port number included (usually :5432)
- All parts present: `postgresql://user:password@host:port/database`
