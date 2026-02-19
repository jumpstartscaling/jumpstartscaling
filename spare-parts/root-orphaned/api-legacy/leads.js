// API endpoint for lead capture
// Add this to your existing server.js or create api/leads.js

const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const router = express.Router();

// Initialize SQLite database
const dbPath = path.join(__dirname, '../data/leads.db');
const db = new sqlite3.Database(dbPath);

// Create leads table if it doesn't exist
db.run(`
  CREATE TABLE IF NOT EXISTS leads (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    industry TEXT,
    revenue TEXT,
    team TEXT,
    bottleneck TEXT,
    utm_source TEXT,
    utm_medium TEXT,
    utm_campaign TEXT,
    page_url TEXT,
    user_agent TEXT,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )
`);

// POST endpoint to capture leads
router.post('/api/leads', express.json(), (req, res) => {
    const {
        name,
        email,
        phone,
        industry,
        revenue,
        team,
        bottleneck,
        utm_source,
        utm_medium,
        utm_campaign,
        page_url,
        userAgent
    } = req.body;

    // Validation
    if (!name || !email) {
        return res.status(400).json({ error: 'Name and email are required' });
    }

    // Insert into database
    const sql = `
    INSERT INTO leads (
      name, email, phone, industry, revenue, team, bottleneck,
      utm_source, utm_medium, utm_campaign, page_url, user_agent
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;

    const params = [
        name, email, phone, industry, revenue, team, bottleneck,
        utm_source, utm_medium, utm_campaign, page_url, userAgent
    ];

    db.run(sql, params, function (err) {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Failed to save lead' });
        }

        console.log(`✅ Lead captured: ${email} (ID: ${this.lastID})`);

        res.json({
            success: true,
            leadId: this.lastID,
            message: 'Lead captured successfully'
        });
    });
});

// GET endpoint to retrieve leads (admin only - add auth later)
router.get('/api/leads', (req, res) => {
    db.all('SELECT * FROM leads ORDER BY submitted_at DESC LIMIT 100', [], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to fetch leads' });
        }
        res.json({ leads: rows });
    });
});

module.exports = router;
