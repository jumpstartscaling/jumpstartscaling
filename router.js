#!/usr/bin/env node
/**
 * Zero-Latency Multi-Domain Router for Astro Sites
 * Routes requests to the correct static site based on domain
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const { URL } = require('url');

const PORT = process.env.PORT || 8100;

// Domain to site directory mapping
const DOMAIN_MAP = {
    'jumpstartscaling.com': './sites/jumpstartscaling/dist',
    'www.jumpstartscaling.com': './sites/jumpstartscaling/dist',
    'chrisamaya.work': './sites/chrisamaya/dist',
    'www.chrisamaya.work': './sites/chrisamaya/dist',
    // Catch-all for direct IP/localhost access
    'localhost': './sites/jumpstartscaling/dist'
};

// MIME types
const MIME_TYPES = {
    '.html': 'text/html',
    '.css': 'text/css',
    '.js': 'text/javascript',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.webp': 'image/webp',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ttf': 'font/ttf',
    '.xml': 'application/xml',
    '.pdf': 'application/pdf'
};

function getSiteRoot(hostname) {
    // Remove port if present
    const domain = hostname.split(':')[0];
    return DOMAIN_MAP[domain] || DOMAIN_MAP['localhost'];
}

function serveFile(res, filePath, contentType) {
    fs.readFile(filePath, (err, data) => {
        if (err) {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('404 Not Found');
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(data);
        }
    });
}

const server = http.createServer((req, res) => {
    const hostname = req.headers.host || 'localhost';
    const siteRoot = getSiteRoot(hostname);

    // Parse URL path
    let urlPath = req.url.split('?')[0];

    // Remove trailing slash for non-root paths
    if (urlPath !== '/' && urlPath.endsWith('/')) {
        urlPath = urlPath.slice(0, -1);
    }

    // Default to index.html for directory requests
    let filePath;
    if (urlPath === '/' || urlPath === '') {
        filePath = path.join(siteRoot, 'index.html');
    } else {
        filePath = path.join(siteRoot, urlPath);

        // If no extension, try .html first (Astro routing)
        if (!path.extname(filePath)) {
            const htmlPath = filePath + '.html';
            if (fs.existsSync(htmlPath)) {
                filePath = htmlPath;
            } else {
                // Try as directory with index.html
                const indexPath = path.join(filePath, 'index.html');
                if (fs.existsSync(indexPath)) {
                    filePath = indexPath;
                }
            }
        }
    }

    // Get file extension and content type
    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    // Check if file exists
    if (fs.existsSync(filePath)) {
        serveFile(res, filePath, contentType);
    } else {
        // Try 404.html if it exists
        const notFoundPath = path.join(siteRoot, '404.html');
        if (fs.existsSync(notFoundPath)) {
            res.writeHead(404, { 'Content-Type': 'text/html' });
            fs.createReadStream(notFoundPath).pipe(res);
        } else {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('404 Not Found');
        }
    }
});

server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Multi-Domain Router running on port ${PORT}`);
    console.log(`📍 Domain mappings:`);
    Object.entries(DOMAIN_MAP).forEach(([domain, dir]) => {
        console.log(`   ${domain} → ${dir}`);
    });
});
