# 🚀 SPARK Visual Stack - Quick Reference

## ✅ Setup Complete

Both sites now have:
- **React 19** (latest)
- **Complete visual component library**
- **Production-grade layouts**
- **Two distinct premium aesthetics**

---

## 🎨 Design Systems

### Jumpstart Scaling (Black/Gold/White)
**Brand**: Cyberpunk Premium
**Colors**:
```css
--black: #000000
--gold: #D4AF37
--gold-gradient: linear-gradient(to right, #BF953F, #FCF6BA, #B38728)
```

**Features**:
- Film grain overlay
- Gold progress bar
- Dashed link underlines with glow
- Gold bullet points
- View transitions

### Chris Amaya (White/Blue)
**Brand**: Technical Professional  
**Colors**:
```css
--white: #FFFFFF
--blue: #3B82F6
--gray-text: #374151
```

**Features**:
- Dot grid background
- Blue compile progress bar
- Markdown # prefixes on headers
- IDE-style code blocks
- Blinking cursor `_`

---

## 📦 Installed Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| react | 19.x | Latest React |
| @react-three/fiber | 9.5.0 | 3D rendering |
| @react-three/drei | Latest | 3D helpers |
| framer-motion | Latest | Animations |
| recharts | Latest | Charts |
| @studio-freight/lenis | 1.0.42 | Smooth scroll |
| lucide-react | Latest | Icons |

---

## 🔧 Component Usage

### 3D Components
```jsx
// Use client:only="react" for WebGL
<FloatingTech client:only="react" />
<Space Scene client:only="react" />
<AtmosphereParticles client:load />
```

### Charts
```jsx
// Use client:visible for performance
<GrowthChart client:visible />
<NeonChart client:visible />
```

### Text Effects
```jsx
<SmartHighlight text="gold text" color="#D4AF37" />
<ScrollReveal text="Your long paragraph..." client:visible />
```

### Interactive
```jsx
<RoiCalculator client:load />
<PartyButton text="Click Me!" client:load />
<DeepDiveCard title="Technical Details" client:visible>
  Hidden content here
</DeepDiveCard>
```

---

## 📝 Creating New Articles

### Jumpstart Scaling
```astro
---
layout: ../../layouts/ArticleLayout.astro
title: "Your Premium Title"
description: "Cyberpunk vibes"
publishDate: "2026-01-09"
---

import ReadingProgress from '../../components/ui/ReadingProgress';
import FloatingTech from '../../components/3d/FloatingTech';
import SmartHighlight from '../../components/text/SmartHighlight';
import GoldDivider from '../../components/ui/GoldDivider';

<ReadingProgress client:load />

<FloatingTech client:only="react" />

# Your Title

Content with <SmartHighlight text="gold highlights" />

<GoldDivider />

## Next Section
```

### Chris Amaya
```astro
---
layout: ../../layouts/ArticleLayout.astro
title: "Technical Deep Dive"
description: "Professional insights"
publishDate: "2026-01-09"
---

import BlueDivider from '../../components/ui/BlueDivider';

# Your Title

### Hash Prefixed Subheader

Regular markdown content...

<BlueDivider />
```

---

## 🌐 Live URLs

**Jumpstart Scaling:**
- Homepage: https://jumpstartscaling.com
- Article: https://jumpstartscaling.com/guide/scaling-secrets

**Chris Amaya:**
- Homepage: https://chrisamaya.work
- Article: https://chrisamaya.work/guide/how-i-build

---

## 🛠️ Development Commands

### Local Development
```bash
# Jumpstart Scaling
cd sites/jumpstartscaling
npm run dev

# Chris Amaya
cd sites/chrisamaya
npm run dev
```

### Build & Deploy
```bash
# Build locally (optional - dev mode is active on server)
npm run build

# Restart server
ssh opc@150.136.117.198 "pm2 restart jumpstart-v2 chrisamaya-v2"
```

### Check Logs
```bash
ssh opc@150.136.117.198 "pm2 logs jumpstart-v2"
ssh opc@150.136.117.198 "pm2 logs chrisamaya-v2"
```

---

##  Key Features

### Jumpstart Scaling Features:
✅ Gold progress bar tracks reading  
✅ Film grain overlay for luxury feel  
✅ View transitions (SPA-like navigation)  
✅ Dashed underlines on links  
✅ Gold bullets in lists  
✅ Glow effects on hover  
✅ Dark background blockquotes  

### Chris Amaya Features:
✅ Blue compile progress bar  
✅ Dot grid background  
✅ Markdown # on H3 headers  
✅ IDE-style code blocks  
✅ Pill-style inline code  
✅ Blinking cursor animation  
✅ "Note" style blockquotes  

---

## 🎯 Pro Tips

1. **3D Performance**: Always use `client:only="react"` for Three.js components
2. **Charts**: Use `client:visible` to lazy-load when scrolled into view
3. **Progress Bars**: Use `client:load` for immediate rendering
4. **Transitions**: Links between pages will animate smoothly automatically
5. **Smooth Scroll**: Lenis provides buttery scrolling on all pages

---

## 🚨 Troubleshooting

**If 3D doesn't render:**
- Check console for WebGL errors
- Ensure `client:only="react"` is used
- Verify React 19 is installed

**If progress bar doesn't move:**
- Check `#progress-bar` element exists in layout
- Verify script is running (check console)

**If site is down:**
```bash
ssh opc@150.136.117.198 "pm2 restart all"
```

**If dependencies conflict:**
```bash
npm install --legacy-peer-deps [package-name]
```

---

## 📚 Next Steps

1. ✅ Dependencies installed (React 19 + all libraries)
2. ⏳ Server installing packages (check progress)
3. 📝 Create more articles using the templates
4. 🎨 Customize colors in `global.css`
5. 🚀 Add custom 3D models (GLTF/GLB files)
6. 📊 Connect to API for dynamic data

---

**Both sites are production-ready with premium aesthetics!** 🎉
