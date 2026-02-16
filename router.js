#!/usr/bin/env node
/**
 * Zero-Latency Multi-Domain Router with Lead Capture (SQLite)
 * Routes requests AND handles form submissions locally.
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const { Pool } = require('pg');
const qs = require('querystring');
require('dotenv').config();

const PORT = process.env.PORT || 8100;
const ADMIN_PASS = 'spark';

// Initialize Postgres Pool
const poolConfig = {
    connectionString: process.env.DATABASE_URL,
    ssl: (process.env.DATABASE_URL && process.env.DATABASE_URL.includes('rds.amazonaws.com'))
        ? { rejectUnauthorized: false }
        : false
};
const pool = new Pool(poolConfig);

// Initialize DB (Postgres)
const initDB = async () => {
    try {
        await pool.query(`
            CREATE TABLE IF NOT EXISTS leads (
                id SERIAL PRIMARY KEY,
                source TEXT,
                name TEXT,
                email TEXT,
                phone TEXT,
                website TEXT,
                revenue TEXT,
                budget TEXT,
                problem TEXT,
                form_type TEXT,
                data_json JSONB,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        `);
        console.log("✅ Postgres Leads table verified");
    } catch (err) {
        console.error("❌ Postgres connection failed:", err.message);
    }
};
initDB();

// Domain Mapping
const DOMAIN_MAP = {
    'jumpstartscaling.com': '/home/opc/sites/jumpstartscaling/dist',
    'www.jumpstartscaling.com': '/home/opc/sites/jumpstartscaling/dist',
    'chrisamaya.work': '/home/opc/sites/chrisamaya/dist',
    'www.chrisamaya.work': '/home/opc/sites/chrisamaya/dist',
    'localhost': '/home/opc/sites/jumpstartscaling/dist'
};

const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.webp': 'image/webp',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2'
};

const COMPRESSIBLE = new Set(['text/html', 'text/css', 'text/javascript', 'application/json', 'image/svg+xml']);

function getSiteRoot(hostname) {
    const domain = hostname.split(':')[0];
    return DOMAIN_MAP[domain] || DOMAIN_MAP['localhost'];
}

/* --- API HANDLERS --- */

function handleLeadSubmit(req, res) {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', async () => {
        let data;
        try {
            if (req.headers['content-type']?.includes('application/json')) {
                data = JSON.parse(body);
            } else {
                data = qs.parse(body);
            }

            const query = `
                INSERT INTO leads (source, name, email, phone, website, revenue, budget, problem, form_type, data_json) 
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
            `;

            const values = [
                data.source || (req.headers.host.includes('chris') ? 'portfolio' : 'jumpstart'),
                data.name || '',
                data.email || '',
                data.phone || '',
                data.website || '',
                data.revenue || '',
                data.budget || '',
                data.problem || data.bottleneck || '',
                data.formType || 'unknown',
                JSON.stringify(data)
            ];

            await pool.query(query, values);

            res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
            res.end(JSON.stringify({ success: true, message: "Lead captured to Postgres" }));

        } catch (e) {
            console.error("Lead submission error:", e);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: "Failed to save lead to Postgres" }));
        }
    });
}

function handleScalingSurveySubmit(req, res) {
    let body = '';
    req.on('data', chunk => { body += chunk.toString(); });
    req.on('end', async () => {
        let data;
        try {
            if (req.headers['content-type']?.includes('application/json')) {
                data = JSON.parse(body);
            } else {
                data = qs.parse(body); // Fallback, though we expect JSON
            }

            const query = `
                INSERT INTO scaling_survey_submissions 
                (name, email, company, role, current_revenue, target_revenue, team_size, industry, challenges, marketing_spend, channels, biggest_goal, raw_data)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
            `;

            const values = [
                data.name,
                data.email,
                data.company,
                data.role,
                data.currentRevenue ? Number(data.currentRevenue) : null,
                data.targetRevenue ? Number(data.targetRevenue) : null,
                data.teamSize ? parseInt(data.teamSize) : null,
                data.industry,
                JSON.stringify(data.challenges || []),
                data.marketingSpend ? Number(data.marketingSpend) : null,
                JSON.stringify(data.channels || []),
                data.biggestGoal,
                JSON.stringify(data)
            ];

            await pool.query(query, values);

            res.writeHead(200, { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' });
            res.end(JSON.stringify({ success: true, message: "Survey submitted successfully" }));

        } catch (e) {
            console.error("Survey submission error:", e);
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: "Failed to save survey to Postgres" }));
        }
    });
}

function handleAdminView(req, res, url) {
    // Check password query param ?key=spark
    const key = new URL(url, `http://${req.headers.host}`).searchParams.get('key');

    if (key !== ADMIN_PASS) {
        res.writeHead(403, { 'Content-Type': 'text/html' });
        res.end('<h1>403 Forbidden</h1><p>Missing or invalid admin key.</p>');
        return;
    }

    pool.query("SELECT * FROM leads ORDER BY created_at DESC", (err, result) => {
        if (err) {
            res.writeHead(500);
            res.end("Postgres Error: " + err.message);
            return;
        }

        const rows = result.rows;

        let html = `
        <!DOCTYPE html>
        <html>
        <head>
            <title>Leads Dashboard</title>
            <style>
                body { font-family: sans-serif; background: #111; color: #eee; padding: 2rem; }
                table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                th, td { border: 1px solid #333; padding: 12px; text-align: left; }
                th { background: #222; color: #C9A961; }
                tr:nth-child(even) { background: #1a1a1a; }
                .badge { padding: 4px 8px; border-radius: 4px; font-size: 0.8rem; font-weight: bold; }
                .js { background: #C9A961; color: #000; }
                .ca { background: #00FF94; color: #000; }
            </style>
        </head>
        <body>
            <h1>🚀 Leads Dashboard</h1>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Source</th>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Phone</th>
                        <th>Details</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
        `;

        rows.forEach(row => {
            const badgeClass = row.source === 'ChrisAmaya' ? 'ca' : 'js';
            const details = row.data_json ? JSON.stringify(JSON.parse(row.data_json), null, 2) : '';
            html += `
                <tr>
                    <td>${row.id}</td>
                    <td><span class="badge ${badgeClass}">${row.source}</span></td>
                    <td>${row.name}</td>
                    <td><a href="mailto:${row.email}" style="color: #4da6ff">${row.email}</a></td>
                    <td>${row.phone}</td>
                    <td>
                        <!-- Core Fields -->
                        ${row.website ? `<div>🌐 ${row.website}</div>` : ''}
                        ${row.revenue ? `<div>💰 ${row.revenue}</div>` : ''}
                        ${row.problem ? `<div>⚠️ ${row.problem}</div>` : ''}
                        
                        <!-- JSON Data Extraction -->
                        ${(() => {
                    try {
                        const d = JSON.parse(row.data_json || '{}');
                        let extra = '';
                        if (d.industry) extra += `<div>🏭 ${d.industry}</div>`;
                        if (d.team) extra += `<div>👥 ${d.team}</div>`;

                        // Tracking Info
                        let tracking = [];
                        if (d.utm_source) tracking.push(`Src: ${d.utm_source}`);
                        if (d.utm_campaign) tracking.push(`Cmp: ${d.utm_campaign}`);
                        if (d.page_url) tracking.push(`Page: ${new URL(d.page_url).pathname}`);

                        if (tracking.length > 0) {
                            extra += `<div style="margin-top:8px; font-size:0.75rem; color:#888; border-top:1px solid #333; padding-top:4px;">
                                        ${tracking.join(' • ')}
                                    </div>`;
                        }
                        return extra;
                    } catch (e) { return ''; }
                })()}
                    </td>
                    <td>${new Date(row.created_at).toLocaleString()}</td>
                </tr>
            `;
        });

        html += `</tbody></table></body></html>`;

        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(html);
    });
}


const server = http.createServer((req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    // Capture API Routes
    if (req.url === '/api/submit-lead' && req.method === 'POST') {
        return handleLeadSubmit(req, res);
    }

    if (req.url === '/api/submit-scaling-survey' && req.method === 'POST') {
        return handleScalingSurveySubmit(req, res);
    }

    if (req.url.startsWith('/admin/leads')) {
        return handleAdminView(req, res, req.url);
    }

    // --- STATIC FILE SERVING (Original Logic) ---
    const hostname = req.headers.host || 'localhost';
    const siteRoot = getSiteRoot(hostname);

    let urlPath = req.url.split('?')[0];
    if (urlPath !== '/' && urlPath.endsWith('/')) urlPath = urlPath.slice(0, -1);

    let filePath;
    if (urlPath === '/' || urlPath === '') {
        filePath = path.join(siteRoot, 'index.html');
    } else {
        filePath = path.join(siteRoot, urlPath);
        if (!path.extname(filePath)) {
            const htmlPath = filePath + '.html';
            if (fs.existsSync(htmlPath)) filePath = htmlPath;
            else {
                const indexPath = path.join(filePath, 'index.html');
                if (fs.existsSync(indexPath)) filePath = indexPath;
            }
        }
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    // Aggressive caching for static assets (1 year for immutable _astro assets)
    let cacheControl = 'public, max-age=0, must-revalidate'; // Default: HTML (no cache)

    if (urlPath.includes('/_astro/')) {
        // Astro assets are content-hashed, safe to cache forever
        cacheControl = 'public, max-age=31536000, immutable';
    } else if (['.woff', '.woff2'].includes(ext)) {
        cacheControl = 'public, max-age=31536000, immutable';
    } else if (['.css', '.js', '.png', '.jpg', '.svg', '.webp', '.ico'].includes(ext)) {
        cacheControl = 'public, max-age=604800';
    }

    if (fs.existsSync(filePath)) {
        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(500);
                res.end('Server Error');
            } else {
                const headers = { 'Content-Type': contentType, 'Cache-Control': cacheControl };
                const ae = req.headers['accept-encoding'] || '';
                if (COMPRESSIBLE.has(contentType) && ae.includes('gzip')) {
                    zlib.gzip(data, (e, compressed) => {
                        if (e) { res.writeHead(200, headers); res.end(data); return; }
                        headers['Content-Encoding'] = 'gzip';
                        headers['Vary'] = 'Accept-Encoding';
                        res.writeHead(200, headers);
                        res.end(compressed);
                    });
                } else {
                    res.writeHead(200, headers);
                    res.end(data);
                }
            }
        });
    } else {
        const notFoundPath = path.join(siteRoot, '404.html');
        if (fs.existsSync(notFoundPath)) {
            res.writeHead(404, { 'Content-Type': 'text/html' });
            fs.createReadStream(notFoundPath).pipe(res);
        } else {
            res.writeHead(404);
            res.end('404 Not Found');
        }
    }
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Multi-Domain Router + Lead Database running on port ${PORT}`);
});
