# ⚠️ CRITICAL: DNS Update Required

**The Cloudflare API Token provided does NOT have permission to update DNS records.**
Attempts to update the A records failed with "Authentication error".

## 🚨 ACTION REQUIRED

You must manually log in to [Cloudflare Dashboard](https://dash.cloudflare.com) and update your DNS records to point to the new server IP.

### New Server IP: `193.122.168.215`

### Records to Update:

| Type | Name | Current Content (OLD) | New Content (CORRECT) | Proxy |
|------|------|-----------------------|-----------------------|-------|
| A | `jumpstartscaling.com` | `150.136.117.198` | **`193.122.168.215`** | Proxied (Orange) |
| A | `www` | `150.136.117.198` | **`193.122.168.215`** | Proxied (Orange) |
| A | `spark` | `150.136.117.198` | **`193.122.168.215`** | DNS Only (Grey) |
| A | `api` | `150.136.117.198` | **`193.122.168.215`** | Proxied (Orange) |
| A | `n8n` | `150.136.117.198` | **`193.122.168.215`** | Proxied (Orange) |

*(And any other subdomains you want to point to the new server)*

---

## ✅ Coolify Terminal Fixed
I have fixed the Coolify Terminal connection issue by:
1.  Authorizing Coolify's internal SSH key on the server.
2.  Switching the Coolify server user from `root` to `opc`.

You should now be able to open the terminal in the Coolify UI.

## 🌐 Site Status
The Next.js site is **RUNNING** and accessible directly via the server IP.
Once you update the DNS A Record in Cloudflare, `https://jumpstartscaling.com` will start working immediately.
