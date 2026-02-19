#!/usr/bin/env node
/**
 * Configure JFactory and god-mode-api in Coolify via API.
 * Sets env vars, port, base directory, domains.
 * Usage: node scripts/configure-coolify-via-api.mjs [--deploy]
 * Requires: COOLIFY_TOKEN in .env.local or env
 * --deploy: trigger redeploy of both apps after config
 */
import { readFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');

const COOLIFY_URL = process.env.COOLIFY_URL || 'http://86.48.23.38:8000';
const APPS = {
  JFactory: 'asws8oco480c8s8k8c408css',
  godModeApi: 'd8ws44sgkcs4wkog8gsokgok',
};

function getToken() {
  let token = process.env.COOLIFY_TOKEN;
  if (!token) {
    for (const f of ['.env.local', '.env']) {
      try {
        const env = readFileSync(resolve(ROOT, f), 'utf8');
        const m = env.match(/COOLIFY_TOKEN[=\s]+([^\s\n#]+)/);
        if (m) {
          token = m[1].trim();
          break;
        }
      } catch (_) {}
    }
  }
  return token;
}

async function api(method, path, body = null) {
  const token = getToken();
  if (!token) {
    throw new Error('Set COOLIFY_TOKEN in .env.local or env. Coolify → Keys & Tokens.');
  }
  const opts = {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  };
  if (body) opts.body = JSON.stringify(body);
  const base = '/api/v1';
  const r = await fetch(`${COOLIFY_URL}${base}${path}`, opts);
  const text = await r.text();
  if (!r.ok) throw new Error(`${r.status} ${path}: ${text}`);
  return text ? JSON.parse(text) : null;
}

async function main() {
  console.log('>>> Configuring Coolify apps via API...\n');

  // Use same ADMIN_KEY for both apps (JFactory proxies /admin to god-mode-api)
  let adminKey = process.env.ADMIN_KEY;
  if (!adminKey) {
    try {
      adminKey = execSync('openssl rand -hex 24', { encoding: 'utf8' }).trim();
    } catch (_) {
      adminKey = 'spark';
    }
  }

  // --- JFactory ---
  console.log('JFactory:');
  try {
    await api('PATCH', `/applications/${APPS.JFactory}`, {
      ports_exposes: '8100',
      custom_docker_run_options: '',
      base_directory: '',
      build_pack: 'dockerfile',
      dockerfile_location: 'Dockerfile',
    });
    console.log('  ✅ Port 8100, docker options cleared');

    await api('PATCH', `/applications/${APPS.JFactory}`, {
      domains: 'https://factory.jumpstartscaling.com,https://www.factory.jumpstartscaling.com,https://chrisamaya.work,https://www.chrisamaya.work',
    });
    console.log('  ✅ Domains set');

    await api('PATCH', `/applications/${APPS.JFactory}/envs/bulk`, {
      data: [
        { key: 'GOD_MODE_API_URL', value: 'https://api.jumpstartscaling.com' },
        { key: 'SITES_BASE_PATH', value: '/app' },
        { key: 'ADMIN_KEY', value: adminKey },
        { key: 'PUBLIC_N8N_WEBHOOK', value: 'https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68' },
      ],
    });
    console.log('  ✅ Env vars: GOD_MODE_API_URL, SITES_BASE_PATH, ADMIN_KEY, PUBLIC_N8N_WEBHOOK');
    console.log(`     ADMIN_KEY=${adminKey}`);
  } catch (e) {
    console.error('  ❌', e.message);
  }

  console.log('');

  // --- god-mode-api ---
  console.log('god-mode-api:');
  try {
    await api('PATCH', `/applications/${APPS.godModeApi}`, {
      ports_exposes: '8200',
      base_directory: 'python-api',
      build_pack: 'dockerfile',
      dockerfile_location: 'Dockerfile',
    });
    console.log('  ✅ Port 8200, Base directory: python-api');

    await api('PATCH', `/applications/${APPS.godModeApi}/envs/bulk`, {
      data: [
        { key: 'ADMIN_KEY', value: adminKey },
        { key: 'LOG_REQUESTS', value: 'false' },
        { key: 'PORT', value: '8200' },
        // DATABASE_URL left unset - app starts without it; add in Coolify if you have Postgres
      ],
    });
    console.log('  ✅ Env vars: ADMIN_KEY (synced), LOG_REQUESTS=false, PORT=8200');
    console.log('     DATABASE_URL not set (add in Coolify if you have Postgres)');
  } catch (e) {
    console.error('  ❌', e.message);
  }

  console.log('\n>>> Done. Redeploy both apps in Coolify.');

  if (process.argv.includes('--deploy')) {
    console.log('\n>>> Triggering deploy...');
    for (const [name, uuid] of Object.entries(APPS)) {
      try {
        await api('POST', '/deploy', { uuid });
        console.log(`  ✅ ${name} deploy triggered`);
      } catch (e) {
        console.error(`  ❌ ${name}:`, e.message);
      }
    }
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
