#!/usr/bin/env node
/**
 * Debug: "No Available Server" (503) - gather runtime evidence from Coolify API and production URLs.
 * Writes NDJSON to .cursor/debug-e58866.log for analysis.
 */
import { readFileSync, appendFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const LOG_PATH = resolve(__dirname, '.cursor/debug-e58866.log');
const COOLIFY_URL = 'http://spark.jumpstartscaling.com:8000';
const APPS = { JFactory: 'asws8oco480c8s8k8c408css', godModeApi: 'd8ws44sgkcs4wkog8gsokgok' };

function log(hypothesisId, message, data) {
  const entry = JSON.stringify({
    sessionId: 'e58866',
    hypothesisId,
    message,
    data: { ...data, timestamp: new Date().toISOString() },
    timestamp: Date.now(),
  }) + '\n';
  appendFileSync(LOG_PATH, entry, 'utf8');
}

async function main() {
  let token = process.env.COOLIFY_TOKEN;
  if (!token) {
    try {
      const env = readFileSync(resolve(__dirname, '.env.local'), 'utf8');
      const m = env.match(/COOLIFY_TOKEN[=\s]+([^\s#]+)/);
      if (m) token = m[1].trim();
    } catch (_) {}
  }
  if (!token) {
    log('INIT', 'No COOLIFY_TOKEN in env or .env.local', { error: 'missing_token' });
    return;
  }

  const auth = { Authorization: `Bearer ${token}` };

  // H1/H2: Container status - fetch apps, deployments
  try {
    const jfRes = await fetch(`${COOLIFY_URL}/api/v1/applications/${APPS.JFactory}`, { headers: auth });
    const jf = await jfRes.json();
    log('H1', 'JFactory app config', {
      name: jf.name,
      ports_exposes: jf.ports_exposes,
      fqdn: jf.fqdn,
      status: jf.status,
      uuid: jf.uuid,
    });

    const apiRes = await fetch(`${COOLIFY_URL}/api/v1/applications/${APPS.godModeApi}`, { headers: auth });
    const api = await apiRes.json();
    log('H2', 'god-mode-api app config', {
      name: api.name,
      ports_exposes: api.ports_exposes,
      fqdn: api.fqdn,
      status: api.status,
      uuid: api.uuid,
    });
  } catch (e) {
    log('H1', 'Coolify API error (JFactory/god-mode-api)', { error: String(e.message) });
  }

  // H3: Port match - already in app config; also check server
  try {
    const srvRes = await fetch(`${COOLIFY_URL}/api/v1/servers`, { headers: auth });
    const servers = await srvRes.json();
    log('H3', 'Server status (port/routing)', {
      servers: servers.map((s) => ({ name: s.name, uuid: s.uuid, reachable: s.is_reachable, usable: s.is_usable })),
    });
  } catch (e) {
    log('H3', 'Servers API error', { error: String(e.message) });
  }

  // H4: Deployment status
  try {
    for (const [label, uuid] of Object.entries(APPS)) {
      const depRes = await fetch(`${COOLIFY_URL}/api/v1/deployments?resource_uuid=${uuid}`, { headers: auth });
      const deps = await depRes.json();
      const latest = Array.isArray(deps) && deps.length ? deps[0] : deps;
      log('H4', `${label} deployment`, {
        status: latest?.status,
        finished_at: latest?.finished_at,
        deployment_uuid: latest?.deployment_uuid,
      });
    }
  } catch (e) {
    log('H4', 'Deployments API error', { error: String(e.message) });
  }

  // H5: Actual HTTP responses from production (proves what user sees)
  const urls = [
    'https://factory.jumpstartscaling.com/',
    'https://factory.jumpstartscaling.com/admin/',
    'https://api.jumpstartscaling.com/',
    'https://api.jumpstartscaling.com/health',
  ];
  for (const url of urls) {
    try {
      const r = await fetch(url, { redirect: 'manual', signal: AbortSignal.timeout(10000) });
      log('H5', 'Production HTTP response', {
        url,
        status: r.status,
        statusText: r.statusText,
        headers: Object.fromEntries([...r.headers].filter(([k]) => k.toLowerCase() === 'content-type')),
      });
    } catch (e) {
      log('H5', 'Production fetch failed', { url, error: String(e.message) });
    }
  }
}

main().catch((e) => {
  try {
    log('INIT', 'Script error', { error: String(e.message), stack: e.stack });
  } catch (_) {}
});
