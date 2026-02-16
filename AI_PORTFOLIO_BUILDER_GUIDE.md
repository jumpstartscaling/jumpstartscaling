# AI Artistic Portfolio Builder Guide (Chris Amaya)

**Purpose**: This document serves as the "Creative Director's Manual" and "Toolbox" for an AI Agent building the `chrisamaya.work` portfolio. This site is NOT just a codebase; it is an **Artistic Interactive Masterpiece**.

---

## 🎨 Creative Direction & Philosophy

**The Vibe**: "Cyber-Renaissance Architect".
- **Visuals**: Dark, moody, high-contrast. Use vivid neon accents (Cyber Green `#00FF94`, Electric Blue `#00B8FF`) against deep blacks (`#050505`).
- **Interaction**: Everything must feel "alive". Hover states, scroll reveals, parallax depth, and 3D manipulations.
- **Typography**: beautiful contrast between `JetBrains Mono` (Code/Technical) and `Inter` (Human/Readable).
- **Anti-Pattern**: Avoid standard "Bootstrap" or "Material Design" layouts. Avoid generic "hacker" tropes like falling green matrix text unless reinvented artistically.

---

## 🛠️ Tech Stack & Dependencies

The project is built on **Astro + React**, leveraging the following high-performance libraries (already installed):

### Core Animation & 3D
1.  **Three.js Ecosystem** (`@react-three/fiber`, `@react-three/drei`, `three`)
    -   *Use Case*: Immersive 3D backgrounds, floating artifacts, interactive hero scenes.
    -   *Example*: `<Canvas><OrbitControls /><Mesh ... /></Canvas>`
2.  **Spline** (`@splinetool/react-spline`)
    -   *Use Case*: Easy integration of complex 3D scenes created in Spline design tool.
    -   *Example*: `<Spline scene="https://prod.spline.design/..." />`
3.  **Rive** (`@rive-app/react-canvas`)
    -   *Use Case*: Vector-perfect, state-machine driven animations (e.g., a mascot that tracks your mouse).
4.  **Framer Motion** (`framer-motion`)
    -   *Use Case*: Page transitions, scroll-triggered reveals (`whileInView`), layout animations (`layoutId`).
    -   *Example*: `<motion.div initial={{opacity:0}} animate={{opacity:1}} />`

### Visual Polish
5.  **Lenis** (`@studio-freight/lenis`)
    -   *Use Case*: Smooth inertial scrolling. Essential for that "premium" feel.
6.  **Canvas Confetti** (`canvas-confetti`)
    -   *Use Case*: Celebration moments (form submission, button clicks).
7.  **Auto Animate** (`@formkit/auto-animate`)
    -   *Use Case*: Effortless list transitions.

---

## 🏗️ Components & Building Blocks

### 1. Immersive Hero Scenes
*Located in `src/components/3d/`*
- **`SpaceScene.jsx`**: A full-screen 3D starfield/cosmos effect.
- **`AtmosphereParticles.jsx`**: Subtle, floating particulate matter.
- **`FloatingTech.jsx`**: 3D geometric shapes representing tech stack elements.

### 2. Interactive UI Elements
*Located in `src/components/interactive/`*
- **`RiveMascot.jsx`**: An interactive character that reacts to cursor position.
- **`RoiCalculator.jsx`**: A functional, gamified ROI calculator.
- **`PartyButton.jsx`**: A button that triggers a confetti explosion on click.

### 3. Text & Layout
*Located in `src/components/text/` & `src/components/ui/`*
- **`SmartHighlight.jsx`**: Highlights text (marker effect) when it enters the viewport.
- **`ScrollReveal.jsx`**: Text that staggers in line-by-line using Framer Motion.
- **`DeepDiveCard.jsx`**: An expandable card for detailed case studies.

---

## 📝 Recipe: How to Build a "Masterpiece" Section

When asking an AI to build a new section, use this structure to ensure it meets the "Artistic" standard:

**1. The "Hook" (Visual)**
Start with a compelling visual anchor using `framer-motion` or a 3D element.
```jsx
<motion.div 
  initial={{ opacity: 0, y: 50 }} 
  whileInView={{ opacity: 1, y: 0 }} 
  viewport={{ once: true }}
>
  <Spline scene="..." /> 
</motion.div>
```

**2. The "Substance" (Content)**
Use the `JetBrains Mono` font for labels and tech specs to ground the art in engineering reality.
```html
<span class="mono-label">SYSTEM ARCHITECTURE</span>
<h2>The Neural Core</h2>
```

**3. The "Interaction" (Micro)**
Make it respond. Don't just show a list; make the list items glow or shift on hover.
```css
.card:hover {
  box-shadow: 0 0 30px var(--accent-primary);
  transform: scale(1.02);
}
```

---

## 🎨 Global Design Tokens (`src/pages/index.astro` style block)

- **Colors**:
  - `var(--bg-dark)`: #050505 (Background)
  - `var(--accent-primary)`: #00FF94 (Cyber Green)
  - `var(--accent-secondary)`: #00B8FF (Electric Blue)
- **Fonts**:
  - `Inter` (Body Copy)
  - `JetBrains Mono` (Headers, Labels, Code)
- **Spacing**:
  - `var(--container-width)`: 900px (Tight, readable container)
