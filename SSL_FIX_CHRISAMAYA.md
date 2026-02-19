# SSL Fix — "Not Secure" in Browser

## Cloudflare SSL Settings (chrisamaya.work & jumpstartscaling.com)

### 1. SSL/TLS mode = **Full** (not Flexible)

1. Cloudflare Dashboard → your domain → **SSL/TLS**
2. Set **Encryption mode** to **Full** or **Full (strict)**
   - **Flexible** = Cloudflare→origin uses HTTP → can cause "Not secure"
   - **Full** = Cloudflare→origin uses HTTPS → secure end-to-end

### 2. Always Use HTTPS

1. **SSL/TLS** → **Edge Certificates**
2. Turn **Always Use HTTPS** ON — redirects `http://` to `https://`

### 3. HSTS (optional, recommended)

- **SSL/TLS** → **Edge Certificates** → **HTTP Strict Transport Security (HSTS)**
- Enable **Enable HSTS** — browser will always use HTTPS

---

## Which domain shows "Not secure"?

| URL | Expected |
|-----|----------|
| https://chrisamaya.work | ✅ Secure (if Cloudflare SSL = Full) |
| https://factory.jumpstartscaling.com | ✅ Secure |
| https://jumpstartscaling.com | ✅ Secure |
| **http://spark.jumpstartscaling.com:8000** | ❌ Always "Not secure" (Coolify UI is HTTP) |

---

## Coolify UI (spark.jumpstartscaling.com:8000)

Runs on HTTP — browser will show "Not secure". Options:

1. **Accept it** — admin-only, use for deployment
2. **Add HTTPS** — configure reverse proxy with SSL, or use Coolify's HTTPS if available
