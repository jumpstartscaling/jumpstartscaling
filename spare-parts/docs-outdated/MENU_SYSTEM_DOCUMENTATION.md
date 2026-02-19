# Menu System Documentation
## Jumpstart Scaling Cyberpunk Command Console

**Last Updated:** 2026-01-11  
**Purpose:** Complete documentation of the menu/navigation system for easy reference and modifications

---

## 📁 File Structure

```
sites/jumpstartscaling/src/
├── components/ui/
│   ├── SystemInterface.jsx       # Main menu component (React)
│   ├── GlobalInterface.astro     # Astro wrapper for menu
│   ├── CyberConsole.css         # All menu styling
│   └── PartyButton.jsx          # Confetti button component (not used in menu)
├── layouts/
│   └── ServiceLayout.astro      # Layout that includes menu
└── pages/
    └── index.astro              # Homepage that includes menu
```

---

## 🎯 Core Components

### 1. **SystemInterface.jsx** 
**Location:** `sites/jumpstartscaling/src/components/ui/SystemInterface.jsx`  
**Type:** React Component (376 lines)  
**Purpose:** Main interactive menu system with cyberpunk/space command theme

#### Features:
- ✅ Bottom navigation bar (sticky)
- ✅ Full-screen modal overlay
- ✅ 3 Tab system: PROTOCOLS, INTEL, SYSTEM
- ✅ Smooth animations with Framer Motion
- ✅ Responsive design (mobile + desktop)
- ✅ Scroll lock when menu is open

#### Current State & Behavior:

**Quick Nav Bar** (Always Visible at Bottom):
- **Menu Button** - Opens full-screen console
- **Audit Button** - Scrolls to survey section (#survey)
- **Charts Button** - Scrolls to visuals section (#visuals)
- **Tools Button** - Scrolls to calculator tools or navigates to /services/paid-acquisition

**Full-Screen Console Tabs:**

1. **PROTOCOLS Tab** (6 Service Cards):
   - Strategic Methodology → `/services/paid-acquisition`
   - Funnel Architecture → `/services/funnel-architecture`
   - CRM Systems → `/services/crm-transformation`
   - Data & Attribution → `/services/data-attribution`
   - Authority Engine → `/services/authority-engine`
   - Growth Retainer → `/services/growth-retainer`

2. **INTEL Tab** (3 Intel Cards):
   - Intel Hub → `/intel`
   - CRM Automation → `/intel/crm-automation-growth`
   - Market Domination → `/intel/market-domination-strategy`

3. **SYSTEM Tab** (Terminal View):
   - System diagnostics display
   - Security status
   - Link to chrisamaya.work mainframe

#### Icons Used (from lucide-react):
```javascript
Terminal, Zap, Database, Award, Briefcase, Cpu, Search, 
BarChart3, Rocket, BarChart2, Calculator, Menu, X, 
Crosshair, ChevronRight, Wifi, Shield, Activity, Target
```

#### Event Listeners:
- `open-system-menu` - Opens the menu
- `toggle-system-menu` - Toggles menu open/closed

---

### 2. **CyberConsole.css**
**Location:** `sites/jumpstartscaling/src/components/ui/CyberConsole.css`  
**Type:** CSS Stylesheet (359 lines)  
**Purpose:** All styling for the cyberpunk command console

#### Key Design Elements:
- **Scanline effect** - Horizontal lines overlay
- **Corner accents** - L-shaped borders at corners
- **Gold accent color** - `#C9A961` (brand gold)
- **Monospace font** - 'JetBrains Mono', 'Courier New'
- **Dark theme** - Black background with subtle glows
- **Hover animations** - Scale, glow, border effects
- **Mobile responsive** - Sidebar becomes horizontal tabs

#### Color Palette:
- Primary Gold: `#C9A961`
- Background: `#000`, `#050505`
- Borders: `#333`, `#555`
- Text: `#fff`, `#888`, `#666`, `#444`
- Success: `#4caf50`
- Warning: `#ff9800`

#### Key CSS Classes:
```css
.quick-nav-react          /* Bottom nav bar */
.quick-link-react         /* Individual nav buttons */
.fullscreen-overlay       /* Dark backdrop */
.cyber-console-container  /* Main console wrapper */
.cyber-screen             /* Inner screen with scanlines */
.cyber-hud-header         /* Top header bar */
.cyber-nav                /* Sidebar navigation */
.cyber-nav-btn           /* Tab buttons */
.cyber-viewport           /* Main content area */
.cyber-grid               /* Card grid layout */
.cyber-card               /* Individual service/intel cards */
.cyber-terminal           /* Terminal view (System tab) */
```

---

### 3. **GlobalInterface.astro**
**Location:** `sites/jumpstartscaling/src/components/ui/GlobalInterface.astro`  
**Type:** Astro Component (8 lines)  
**Purpose:** Wrapper to load SystemInterface with proper Astro hydration

```astro
---
import SystemInterface from './SystemInterface.jsx';
---

<!-- Global System Interface (Modal + QuickNav) -->
<!-- Placed here to ensure it's at the root z-index level -->
<SystemInterface client:load />
```

**Note:** `client:load` directive ensures React component hydrates immediately on page load.

---

## 🔗 Integration Points

### Where the Menu is Used:

1. **Homepage** (`pages/index.astro`)
   - Imported at line 9
   - Rendered at line 221 (near body close)

2. **Service Pages** (`layouts/ServiceLayout.astro`)
   - Imported at line 4
   - Rendered at line 49 (near body close)

### How to Add Menu to Other Pages:
```astro
---
import GlobalInterface from '../components/ui/GlobalInterface.astro';
---

<html>
  <body>
    <!-- Your page content -->
    
    <!-- Menu at bottom of body -->
    <GlobalInterface />
  </body>
</html>
```

---

## 🎨 Menu Data Structure

### PROTOCOLS (Services)
```javascript
const protocols = [
  {
    label: 'Strategic Methodology',
    desc: 'Scaling Roadmap',
    href: '/services/paid-acquisition',
    icon: Search,
    id: 'P-01'
  },
  // ... 5 more
];
```

### INTEL (Content Pages)
```javascript
const intel = [
  {
    label: 'Intel Hub',
    desc: 'All Intelligence Files',
    href: '/intel',
    icon: Cpu,
    id: 'INT-00'
  },
  {
    label: 'CRM Automation',
    desc: 'Growth Strategy',
    href: '/intel/crm-automation-growth',
    icon: Database,
    id: 'INT-01'
  },
  {
    label: 'Market Domination',
    desc: 'Strategy Guide',
    href: '/intel/market-domination-strategy',
    icon: Target,
    id: 'INT-02'
  }
];
```

---

## 🛠️ Common Modifications

### Adding a New Service to PROTOCOLS Tab

**File:** `SystemInterface.jsx` (line 73-80)

```javascript
const protocols = [
  // ... existing items
  {
    label: 'Your New Service',
    desc: 'Short Description',
    href: '/services/your-service-url',
    icon: YourIcon,  // Import from lucide-react
    id: 'P-07'
  }
];
```

### Adding a New Intel Page to INTEL Tab

**File:** `SystemInterface.jsx` (line 214-217)

```javascript
{
  label: 'New Intel Page',
  desc: 'Description',
  href: '/intel/page-slug',
  icon: YourIcon,
  id: 'INT-03'
}
```

### Changing Menu Colors

**File:** `CyberConsole.css`

Replace `#C9A961` (gold) with your new color throughout the file.

Key locations:
- Line 26, 36, 75, 106, 231, 257, etc.

### Adding a New Tab

**File:** `SystemInterface.jsx`

1. Add state handler (line 28):
```javascript
const [activeTab, setActiveTab] = useState('protocols');
```

2. Add button in sidebar (line 154-173):
```javascript
<button
  className={`cyber-nav-btn ${activeTab === 'newtab' ? 'active' : ''}`}
  onClick={() => setActiveTab('newtab')}
>
  <YourIcon size={16} /> NEW TAB
</button>
```

3. Add content in viewport (line 176-266):
```javascript
{activeTab === 'newtab' && (
  <div className="cyber-grid">
    {/* Your content */}
  </div>
)}
```

---

## 📱 Mobile Behavior

**Breakpoint:** `768px`

### Changes on Mobile:
- Sidebar navigation becomes horizontal tabs at top
- Tab buttons use bottom border instead of left border
- HUD metrics hidden
- Viewport padding reduced
- Console height becomes 95vh
- Grid columns reduce to 1 column

---

## 🎭 Animation Details

**Library:** Framer Motion

### Overlay Animation:
```javascript
initial={{ opacity: 0 }}
animate={{ opacity: 1 }}
exit={{ opacity: 0 }}
transition={{ duration: 0.3 }}
```

### Console Container Animation:
```javascript
initial={{ scale: 0.9, opacity: 0 }}
animate={{ scale: 1, opacity: 1 }}
exit={{ scale: 0.9, opacity: 0 }}
transition={{ type: "spring", damping: 25, stiffness: 300 }}
```

### Card Stagger Animation:
```javascript
initial={{ opacity: 0, y: 20 }}
animate={{ opacity: 1, y: 0 }}
transition={{ delay: i * 0.05 }}
whileHover={{ scale: 1.02, y: -5 }}
```

---

## 🔧 Dependencies

**Required npm packages:**
```json
{
  "react": "^19.0.0",
  "framer-motion": "^11.x",
  "lucide-react": "^0.x"
}
```

---

## 🚀 Quick Commands

### Sync Menu to Server:
```bash
cd /Users/christopheramaya/Downloads/spark/god-mode
bash sync_sites.sh
```

### Rebuild on Server:
```bash
ssh -i ~/.ssh/id_rsa opc@150.136.117.198 'cd ~/sites/jumpstartscaling && npm run build && pm2 restart jumpstartscaling'
```

### Purge Cloudflare Cache:
```bash
export CLOUDFLARE_API_TOKEN="nqsfbN92BBmUR1l1nxbMFUPGbImmB8nyUeNsU0u2"
export CLOUDFLARE_ZONE_ID="f1e606b93260b3e12a939612c12c6370"
bash purge-cloudflare-cache.sh
```

---

## 💡 Design Philosophy

The menu system follows a **cyberpunk/space command** aesthetic:
- Terminal/console inspired interface
- Monospace fonts for technical feel
- Gold (#C9A961) as primary accent (brand color)
- Scanlines for retro-futuristic effect
- L-corner brackets for military/tech aesthetic
- Smooth animations for premium feel
- High contrast for readability

**User Experience Goals:**
- Always accessible (fixed bottom nav)
- Quick access to all services and content
- Non-intrusive (can close by clicking outside)
- Mobile-friendly
- Fast animations (no lag)

---

## 📝 Notes for Future Developers

1. **Z-Index Management:** Menu uses z-index `9900` (nav) and `10000` (overlay)
2. **Scroll Locking:** Body overflow is managed when menu opens
3. **Event System:** Uses custom events for external triggers
4. **Navigation Logic:** Handles both hash links and page navigation
5. **CSS Organization:** All styles in one file for easier maintenance

---

## 🔍 Troubleshooting

### Menu Not Appearing
- Check if `<GlobalInterface />` is in the page
- Verify React hydration with `client:load`
- Check browser console for import errors

### Styling Issues
- Ensure `CyberConsole.css` is imported in `SystemInterface.jsx`
- Check if CSS is being overridden by other stylesheets
- Verify z-index values

### Navigation Not Working
- Check href values in protocols/intel arrays
- Verify target elements exist for hash navigation
- Check console for JavaScript errors

---

**End of Documentation**

For modifications or questions, refer to this document first before making changes.
