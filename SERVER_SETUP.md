# Server Setup & Environment Documentation

**Last Updated:** January 31, 2026  
**Machine:** Christopher's MacBook Pro  
**Location:** `/Users/christopheramaya/Downloads/spark/god-mode`

---

## 🖥️ System Information

### Hardware Specifications
- **CPU:** ARM64 (Apple Silicon) - 8 Cores
- **RAM:** 8.00 GB
- **Architecture:** arm64e (Apple M-series chip)
- **Disk Space:**
  - Total: 228 GB
  - Used: 11 GB
  - Available: 10 GB
  - Usage: 53%

### Operating System
- **OS:** macOS 26.1 (Build 25B78)
- **Kernel:** Darwin 25.1.0
- **Full Kernel:** Darwin Kernel Version 25.1.0 (RELEASE_ARM64_T8112)

---

## 🛠️ Development Tools & Package Managers

### Core Tools
| Tool | Version | Location |
|------|---------|----------|
| **Git** | 2.50.1 (Apple Git-155) | `/usr/bin/git` |
| **Homebrew** | 5.0.11 | `/opt/homebrew/bin/brew` |
| **SSH** | System Default | `/usr/bin/ssh` |

### Package Manager Versions
- **npm:** 10.9.4
- **pip3:** 23.2.1 (update available to 26.0)
- **Homebrew:** 5.0.11

---

## 💻 Scripting Languages & Runtimes

### Node.js
- **Version:** v22.21.1
- **Location:** `/Users/christopheramaya/.nvm/versions/node/v22.21.1/`
- **Package Manager:** npm 10.9.4
- **Global Packages:**
  - `corepack@0.34.0`
  - `npm@10.9.4`

### Python
- **Version:** Python 3.12.1
- **Package Manager:** pip3 23.2.1
- **Major Installed Packages:**
  - `aiohttp` 3.12.15
  - `streamlit` 1.52.2
  - `beautifulsoup4` 4.13.4
  - `cryptography` 46.0.3
  - `requests` (via dependencies)
  - `tiktoken` 0.10.0 (OpenAI tokenizer)
  - `tokenizers` 0.21.4
  - `google-*` libraries (Cloud SDK)
  - `typer` 0.21.1 (CLI framework)
  - `uvicorn` 0.34.0 (ASGI server)
  - `websockets` 15.0.1
  - `xonsh` 0.22.1 (Python-powered shell)

### Ruby
- **Version:** 2.6.10p210 (2022-04-12)
- **Platform:** universal.arm64e-darwin25

### Languages Not Installed
- ❌ **PHP** - Not installed
- ❌ **Go** - Not installed

---

## 📦 Node.js Projects & Modules

### Project Structure
```
god-mode/
├── package.json (root - multisite config)
├── sites/
│   ├── jumpstartscaling/package.json
│   └── chrisamaya/package.json
└── universe/
    ├── package.json
    ├── benchmark/package.json
    └── scripts/package.json
```

### Root Project (`jumpstart-multisite`)
**Primary Dependencies:**
- `astro` ^5.1.5
- `@astrojs/tailwind` ^6.1.0
- `@astrojs/sitemap` ^3.3.3
- `tailwindcss` ^3.4.17

**Dev Dependencies:**
- `@types/node` ^22.10.5
- `typescript` ^5.7.3

**Scripts:**
```json
{
  "dev": "astro dev --host",
  "build": "astro build",
  "preview": "astro preview --host",
  "deploy": "npm run build && ./deploy.sh"
}
```

### Jumpstart Scaling Site
**Framework:** Astro v5.16.8  
**Build Tool:** Vite (via Tailwind v4.1.18)

**Key Dependencies:**
- **UI Frameworks:**
  - `react` ^19.2.3
  - `react-dom` ^19.2.3
  - `framer-motion` ^12.25.0
  - `@formkit/auto-animate` ^0.9.0

- **3D & Graphics:**
  - `three` ^0.182.0
  - `@react-three/fiber` ^9.5.0
  - `@react-three/drei` ^10.7.7
  - `@react-three/cannon` ^6.6.0 (physics)
  - `@splinetool/react-spline` ^4.1.0
  - `@rive-app/react-canvas` ^4.25.3

- **Styling:**
  - `tailwindcss` ^4.1.18
  - `@tailwindcss/vite` ^4.1.18
  - `tailwind-merge` ^3.4.0
  - `clsx` ^2.1.1

- **Animation & Effects:**
  - `@studio-freight/lenis` ^1.0.42 (smooth scroll)
  - `canvas-confetti` ^1.9.4
  - `react-rough-notation` ^1.0.8

- **Charts & Data Viz:**
  - `recharts` ^3.6.0

- **Content:**
  - `@astrojs/mdx` ^4.3.13

- **Analytics:**
  - `@microsoft/clarity` ^1.0.2

- **Utilities:**
  - `lucide-react` ^0.562.0 (icons)
  - `maath` ^0.10.8 (math utilities)

**Scripts:**
```json
{
  "dev": "astro dev --port 8100 --host",
  "build": "astro build",
  "preview": "node server.js",
  "astro": "astro"
}
```

---

## 🐍 Python Modules (Full List)

### Web & API Frameworks
- `aiohttp` 3.12.15 - Async HTTP client/server
- `starlette` 0.41.3 - ASGI framework
- `uvicorn` 0.34.0 - ASGI server
- `websockets` 15.0.1 - WebSocket implementation

### Data Processing
- `beautifulsoup4` 4.13.4 - HTML/XML parsing
- `soupsieve` 2.7 - CSS selector library
- `arrow` 1.4.0 - Better dates & times
- `tzdata` 2025.3 - Timezone database

### UI & Visualization
- `streamlit` 1.52.2 - Data app framework
- `altair` 6.0.0 - Declarative visualization

### AI & ML Tools
- `tiktoken` 0.10.0 - OpenAI's tokenizer
- `tokenizers` 0.21.4 - HuggingFace tokenizers
- `backoff` 2.2.1 - Function retry with backoff

### CLI & Shell
- `typer` 0.21.1 - CLI framework
- `click` 8.2.1 - Command-line interface creation
- `xonsh` 0.22.1 - Python-powered shell
- `coloredlogs` 15.0.1 - Colored terminal logs
- `blessed` 1.27.0 - Terminal formatting
- `wcwidth` 0.2.14 - Terminal width calculation

### Security & Cryptography
- `cryptography` 46.0.3 - Cryptographic recipes
- `cffi` 2.0.0 - C Foreign Function Interface
- `pycparser` - C parser
- `sslpsk-pmd3` 1.0.3 - SSL PSK support
- `srptools` 1.0.1 - Secure Remote Password

### File & Data Formats
- `construct` 2.10.70 - Binary data parser
- `construct-typing` 0.7.0 - Type hints for construct
- `toml` 0.10.2 - TOML parser
- `tree-sitter` 0.24.0 - Parser generator
- `tree-sitter-language-pack` 0.9.0

### Compression & Archives
- `apple-compress` 0.2.3 - Apple compression algorithms
- `bpylist2` 4.1.1 - Binary plist parser

### HTTP & Networking
- `urllib3` 2.5.0 - HTTP client
- `requests` (via dependencies)
- `certifi` 2025.8.3 - Root certificates
- `charset-normalizer` 3.4.2 - Character encoding detection
- `aiohappyeyeballs` 2.6.1 - Async happy eyeballs
- `socksio` 1.0.0 - SOCKS proxy support

### Development & Debugging
- `watchdog` 6.0.0 - File system event monitor
- `watchfiles` 1.1.0 - Fast file watcher
- `traitlets` 5.14.3 - Configuration system
- `asttokens` 3.0.1 - Annotate AST with token info
- `stack-data` 0.6.3 - Stack frame data extraction

### Configuration & Parsing
- `ConfigArgParse` 1.7.1 - Argparse + config files
- `shtab` 1.7.2 - Shell completion generator
- `shellingham` 1.5.4 - Shell detection

### Google Cloud
- `google-*` packages (via gcloud SDK)
- `cachetools` 5.5.2 - Caching utilities

### Audio
- `sounddevice` 0.5.2 - Audio I/O
- `soundfile` 0.13.1 - Audio file I/O

### Utilities
- `tqdm` 4.67.1 - Progress bars
- `tenacity` 9.1.2 - Retry library
- `termcolor` 3.3.0 - Terminal color
- `six` 1.17.0 - Python 2/3 compatibility
- `cached-property` 2.0.1 - Cached property decorator
- `attrs` 25.3.0 - Classes without boilerplate
- `anyio` 4.10.0 - Async compatibility layer
- `sniffio` 1.3.1 - Async library detection
- `smmap` 5.0.2 - Memory-mapped file support
- `ujson` 5.11.0 - Ultra fast JSON
- `tornado` 6.5.4 - Web framework
- `zipp` 3.23.0 - Backport of zipfile

---

## ☁️ Cloud & Deployment Tools

### Google Cloud SDK
- **Version:** 550.0.0
- **Location:** `/Users/christopheramaya/google-cloud-sdk/`
- **Components:**
  - `gcloud` CLI (core 2025.12.12)
  - `bq` 2.1.26 (BigQuery)
  - `gsutil` 5.35 (Cloud Storage)
  - `gcloud-crc32c` 1.0.0

**Note:** Updates available - run `gcloud components update`

---

## 📱 Mobile Development Tools

### Android Debug Bridge (ADB)
- **Version:** 1.0.41 (Build 36.0.2-14143358)
- **Location:** `/opt/homebrew/bin/adb`
- **Platform:** Darwin 25.1.0 (arm64)

### scrcpy (Screen Mirror)
- **Version:** 3.3.4
- **Location:** `/opt/homebrew/bin/scrcpy`
- **Dependencies:**
  - SDL: 2.32.10
  - libavcodec: 62.11.100
  - libavformat: 62.3.100
  - libavutil: 60.8.100
  - libusb: 1.0.29

**Purpose:** Wireless headless Android device control

---

## 🔐 SSH Keys & Authentication

Located in `~/.ssh/`:

| Key Name | Type | Purpose |
|----------|------|---------|
| `god_mode_deploy.pub` | ED25519 | Deployment key for god-mode project |
| `google_compute_engine.pub` | RSA | Google Cloud Compute authentication |
| `id_ed25519.pub` | ED25519 | General purpose SSH key |
| `id_gitea_spark.pub` | ED25519 | Gitea repository access (spark) |
| `id_rsa.pub` | RSA | Legacy RSA key |
| `oracle_ubuntu.pub` | ED25519 | Oracle Cloud Ubuntu instances |
| `spark_deploy_key.pub` | ED25519 | Spark deployment automation |

---

## 🚀 Deployment Scripts

Located in workspace root:
- `deploy.sh` - General deployment script
- `deploy-html.sh` - HTML site deployment
- Various `Moto_WiFi_Headless.command` - Android device connection scripts

---

## 🌐 Web Frameworks & Build Tools

### Primary Stack
- **Astro** 5.16.8 (primary SSG framework)
- **React** 19.2.3 (UI components)
- **Tailwind CSS** 4.1.18 (styling)
- **Vite** (via Tailwind v4 - build tool)

### Additional Frameworks
- **Streamlit** 1.52.2 (Python data apps)
- **Starlette** 0.41.3 (ASGI framework)
- **Uvicorn** 0.34.0 (ASGI server)

---

## 📊 Development Workflow

### Available Commands

**Root Level:**
```bash
npm run dev      # Start Astro dev server (all sites)
npm run build    # Build all sites
npm run preview  # Preview built sites
npm run deploy   # Build and deploy
```

**Jumpstart Scaling Site:**
```bash
cd sites/jumpstartscaling
npm run dev      # Dev server on port 8100
npm run build    # Build production bundle
npm run preview  # Preview with Node server
```

### Port Configuration
- **Jumpstart Scaling:** Port 8100
- **Chris Amaya Site:** Default Astro port
- **Root Multisite:** Default host binding

---

## 🗂️ Project Structure

```
god-mode/
├── sites/
│   ├── jumpstartscaling/          # Astro site (main product)
│   ├── jumpstartscaling-html/     # Pure HTML version
│   └── chrisamaya/                # Personal site
├── universe/                       # Additional tooling
│   ├── benchmark/
│   ├── scripts/
│   └── package.json
├── deploy.sh                       # Deployment automation
├── deploy-html.sh                  # HTML deployment
└── package.json                    # Root multisite config
```

---

## 💾 Database & Storage

### Local Development
- No local database servers configured
- Static file generation (Astro SSG)
- Form submissions likely handled via serverless functions

### Cloud Storage
- Google Cloud SDK installed
- BigQuery tools available (`bq`)
- Cloud Storage utilities (`gsutil`)

---

## 🔧 System Capabilities

### ✅ Available
- Static site generation (Astro)
- React component development
- 3D graphics rendering (Three.js)
- Python scripting & automation
- Google Cloud deployment
- Android device debugging
- SSH/SFTP deployment
- Git version control
- Shell scripting (zsh)

### ⚠️ Limited/Not Available
- PHP development (not installed)
- Go development (not installed)
- Local database servers
- Docker/containerization (not verified)

---

## 📝 Notes & Recommendations

### Immediate Actions Recommended
1. **Update pip:** `pip3 install --upgrade pip` (23.2.1 → 26.0)
2. **Update gcloud:** `gcloud components update`
3. **Disk Space:** Monitor usage (currently at 53%, only 10GB available)

### Performance Considerations
- 8GB RAM may be limiting for large 3D scenes in browser
- Consider clearing `node_modules` from unused projects
- The sites_upload.tar.gz (198MB) could be archived elsewhere

### Security Notes
- Multiple SSH keys configured for different services
- Google Cloud authentication active
- Review and rotate keys periodically

---

**End of Documentation**
