# JFactory — Coolify Configuration

Use these values to configure the JFactory app in Coolify.

---

## General

| Field | Value |
|-------|-------|
| **Name** | JFactory |
| **Description** | God-mode router + jumpstartscaling + chrisamaya sites |
| **Build Pack** | Dockerfile |

---

## Domains

Replace `https://coolify.io` with your actual domains:

| Domain |
|--------|
| `factory.jumpstartscaling.com` |
| `www.factory.jumpstartscaling.com` |
| `chrisamaya.work` |
| `www.chrisamaya.work` |

**Direction:** Allow www & non-www.

---

## Build

| Field | Value |
|-------|-------|
| **Base Directory** | (leave empty or `/`) |
| **Dockerfile Location** | `Dockerfile` |
| **Docker Build Stage Target** | (leave empty) |
| **Custom Docker Options** | (leave empty — remove the long SYS_ADMIN/fuse string; our app doesn't need it) |

---

## Git Source

- **Repository:** `jumpstartscaling/jumpstartscaling` (or your GitHub org/repo)
- **Branch:** `main`

---

## Environment Variables

Add these (replace placeholders with real values):

| Variable | Value |
|----------|-------|
| `GOD_MODE_API_URL` | `https://api.jumpstartscaling.com` |
| `SITES_BASE_PATH` | `/app` |
| `ADMIN_KEY` | Generate: `openssl rand -hex 24` |
| `PUBLIC_N8N_WEBHOOK` | `https://n8n.jumpstartscaling.com/webhook/d282e622-9c83-4936-9d93-05c37eaa7b68` |

---

## Prerequisites

1. **God-mode API** must be deployed first at `api.jumpstartscaling.com` (separate Coolify app).
2. **DNS:** A records for the domains above → your Coolify server IP (e.g. `86.48.23.38`).

---

## Deploy

Click **Deploy** after saving. The first build may take several minutes (builds both Astro sites).
