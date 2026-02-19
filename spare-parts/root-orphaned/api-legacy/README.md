# Lead Capture System - SQLite Backend

## Setup Instructions

### 1. Add to your existing Node.js server

If you already have `server.js` or `router.js`, add this line:

```javascript
const leadsRouter = require('./api/leads');
app.use(leadsRouter);
```

### 2. Install SQLite dependency (if not already installed)

```bash
npm install sqlite3
```

### 3. The database will auto-create at:
```
/home/opc/data/leads.db
```

## API Endpoints

### POST /api/leads
Captures a new lead and saves to SQLite database.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@company.com",
  "phone": "+1234567890",
  "industry": "B2B / SaaS",
  "revenue": "$50k - $200k",
  "team": "Small In-House",
  "bottleneck": "Lead Quality",
  "utm_source": "google",
  "utm_medium": "cpc",
  "utm_campaign": "q1-growth",
  "page_url": "https://jumpstartscaling.com/?utm_source=google",
  "userAgent": "Mozilla/5.0..."
}
```

**Response:**
```json
{
  "success": true,
  "leadId": 42,
  "message": "Lead captured successfully"
}
```

### GET /api/leads
Retrieves last 100 leads (add authentication before production!)

## View Leads

SSH into server and run:
```bash
sqlite3 /home/opc/data/leads.db "SELECT * FROM leads ORDER BY submitted_at DESC LIMIT 10;"
```

Or export to CSV:
```bash
sqlite3 -header -csv /home/opc/data/leads.db "SELECT * FROM leads;" > leads.csv
```

## How It Works

1. User fills out survey on website
2. JavaScript saves to **localStorage** (backup)
3. JavaScript POSTs to `/api/leads`
4. Server saves to **SQLite database**
5. You can query the database anytime

**Backup:** Even if the API fails, the lead is saved in the browser's localStorage under the key `jumpstart_leads`.
