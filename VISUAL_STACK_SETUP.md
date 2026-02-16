# 🎨 Visual Stack Setup Complete

## Two Distinct Design Systems Created

### 1. **Jumpstart Scaling** - Cyberpunk Premium (Black, Gold, White)
- **Background**: Pure Black (#000000)
- **Primary Accent**: Gold (#D4AF37)
- **Text**: White (#FFFFFF)
- **Aesthetic**: High-performance, futuristic, premium
- **URL**: https://jumpstartscaling.com

### 2. **Chris Amaya** - Professional Clean (White, Blue)
- **Background**: White (#FFF FFF)
- **Primary Accent**: Blue (#3B82F6)
- **Text**: Gray-900 (#1F2937)
- **Aesthetic**: Clean, professional, technical
- **URL**: https://chrisamaya.work

---

## 📦 Complete Component Library

### 3D Components (`src/components/3d/`)
- `FloatingTech.jsx` - Interactive distorted sphere
- `SpaceScene.jsx` - Wireframe rotating box with starfield
- `AtmosphereParticles.jsx` - Subtle particle background

### Charts (`src/components/charts/`)
- `GrowthChart.jsx` - Line chart with dark theme
- `NeonChart.jsx` - Area chart with neon gradient

### Text Effects (`src/components/text/`)
- `SmartHighlight.jsx` - Hand-drawn style underlines/circles
- `ScrollReveal.jsx` - Word-by-word scroll reveal animation

### UI Components (`src/components/ui/`)
- `PartyButton.jsx` - Confetti CTA button
- `ReadingProgress.jsx` - Scroll progress bar
- `DeepDiveCard.jsx` - Collapsible content card
- `GoldDivider.astro` (Jumpstart) - Premium gold section divider
- `BlueDivider.astro` (Chris) - Clean blue section divider

### Interactive (`src/components/interactive/`)
- `RoiCalculator.jsx` - Interactive ROI calculator
- `RiveMascot.jsx` - Animated mascot for forms

### SEO Components (`src/components/seo/`)
- `SEOMetadata.astro` - Open Graph & Twitter Cards
- `SchemaJSON.astro` - Structured data for Google

---

## 📄 Example Pages Created

### Jumpstart Scaling
- `src/pages/index.astro` - Homepage with 3D components
- `src/pages/guide/scaling-secrets.mdx` - 2000+ word interactive article

### Chris Amaya
- `src/pages/index.astro` - Portfolio homepage
- `src/pages/guide/how-i-build.mdx` - Technical deep-dive article

---

## 🚀 Installation & Deployment

### Step 1: Install Dependencies

Run the installation script (installs locally + remotely):

```bash
chmod +x ./install_visual_stack.sh
./install_visual_stack.sh
```

This will:
- Install MDX, Tailwind, React integrations
- Install all visual libraries (Three.js, Framer Motion, Recharts, etc.)
- Sync files to Oracle server
- Restart PM2 services

### Step 2: Verify astro.config.mjs

**CRITICAL**: After installation, verify these files still have `allowedHosts`:

**sites/jumpstartscaling/astro.config.mjs:**
```javascript
export default defineConfig({
  integrations: [react(), tailwind(), mdx()],
  vite: {
    server: {
      allowedHosts: ['jumpstartscaling.com', 'www.jumpstartscaling.com', 'localhost']
    }
  }
});
```

**sites/chrisamaya/astro.config.mjs:**
```javascript
export default defineConfig({
  integrations: [react(), tailwind(), mdx()],
  vite: {
    server: {
      allowedHosts: ['chrisamaya.work', 'www.chrisamaya.work', 'localhost']
    }
  }
});
```

### Step 3: Deploy

```bash
./sync_sites.sh
```

### Step 4: Test

Visit:
- https://jumpstartscaling.com
- https://jumpstartscaling.com/guide/scaling-secrets
- https://chrisamaya.work
- https://chrisamaya.work/guide/how-i-build

---

## 🎨 Using Components in MDX

### Example Article Structure

```mdx
---
layout: ../../layouts/ArticleLayout.astro
title: "Your Title"
description: "Your description"
---

import ReadingProgress from '../../components/ui/ReadingProgress';
import FloatingTech from '../../components/3d/FloatingTech';
import SmartHighlight from '../../components/text/SmartHighlight';
import GoldDivider from '../../components/ui/GoldDivider'; // or BlueDivider for Chris

{/* Always-present UI */}
<ReadingProgress client:load />

{/* 3D Hook */}
<FloatingTech client:only="react" />

# Your Title

Regular markdown text with <SmartHighlight text="highlighted phrases" /> inline.

<GoldDivider />

## Next Section

More content...
```

### Component Hydration Directives

- `client:load` - Load immediately on page load (use for critical UI like progress bars)
- `client:visible` - Load when scrolled into view (use for charts, calculators)
- `client:only="react"` - Only render in browser (use for 3D components that need `window`)

---

## 🎯 Color Palette Reference

### Jumpstart Scaling (Cyberpunk)
```css
/* Backgrounds */
--bg-primary: #000000;

/* Gold Accents */
--gold: #D4AF37;
--gold-light: #FCF6BA;
--gold-dark: #AA771C;

/* Text */
--text-primary: #FFFFFF;
--text-secondary: #E5E5E5;

/* Gold Gradient */
background: linear-gradient(to right, #BF953F, #FCF6BA, #B38728, #FBF5B7, #AA771C);
```

### Chris Amaya (Professional)
```css
/* Backgrounds */
--bg-primary: #FFFFFF;
--bg-secondary: #F3F4F6;

/* Blue Accents */
--blue-primary: #3B82F6;
--blue-dark: #1E40AF;
--blue-light: #60A5FA;

/* Text */
--text-primary: #1F2937;
--text-secondary: #374151;

/* Blue Gradient */
background: linear-gradient(to right, #1E40AF, #3B82F6, #60A5FA);
```

---

## 📊 Full Library Inventory

| Category | Library | Purpose |
|----------|---------|---------|
| **Core** | framer-motion | Animations |
| **Core** | clsx, tailwind-merge | Class management |
| **3D** | three, @react-three/fiber | 3D rendering |
| **3D** | @react-three/drei | 3D helpers |
| **3D** | @react-three/cannon | Physics |
| **3D** | @splinetool/react-spline | Spline 3D scenes |
| **Charts** | recharts | Data visualization |
| **UX** | @studio-freight/lenis | Smooth scrolling |
| **UX** | @rive-app/react-canvas | Interactive mascots |
| **UX** | react-rough-notation | Hand-drawn text effects |
| **UX** | canvas-confetti | Confetti animations |
| **UX** | @formkit/auto-animate | Auto layout transitions |
| **Icons** | lucide-react | Icon library |
| **Utils** | maath | Math utilities for 3D |

---

## 🛠️ Troubleshooting

### If 3D components don't load:
- Ensure `client:only="react"` is used (not `client:load`)
- Check browser console for WebGL errors

### If Tailwind classes don't work:
- Verify `tailwind.config.mjs` exists in site root
- Check `global.css` is imported in layout

### If smooth scrolling doesn't work:
- Install dependencies: `npm install @studio-freight/lenis`
- Check script is in layout file

### If site goes down:
```bash
ssh opc@150.136.117.198 "pm2 restart jumpstart-v2 chrisamaya-v2"
```

---

## 📝 Next Steps

1. **Run the installation script** to install all dependencies
2. **Verify config files** preserve `allowedHosts`
3. **Deploy with sync script**
4. **Test both sites** live
5. **Create more articles** using the MDX templates
6. **Add custom 3D models** (GLTF/GLB files)
7. **Build lead capture forms** with interactive components

---

**Ready to see magic happen!** 🚀
