# AI Page Builder Guide (JumpStart Scaling)

**Purpose**: This document serves as the "Menu" and "Instruction Manual" for an AI Agent (or developer) to build new pages for the JumpStart Scaling website. Use these pre-built, styled components to ensure consistency and premium aesthetics.

---

## 🏗️ Layouts (The Foundation)

Always wrap your page content in one of these layouts. They handle SEO metadata, fonts, global styles, and navigation.

### 1. `ServiceLayout.astro`
**Best for:** Landing pages, Service pages, Sales pages.
**Imports:** `import ServiceLayout from '../../layouts/ServiceLayout.astro';`
**Props:**
- `title` (string): Browser tab title.
- `description` (string): Meta description for SEO.
- `currentPath` (string): URL path (e.g., `/services/funnel-architecture`).

**Example:**
```astro
<ServiceLayout 
  title="Page Title | Jumpstart Scaling" 
  description="SEO description here." 
  currentPath="/your-path"
>
  <!-- Your content here -->
</ServiceLayout>
```

### 2. `ArticleLayout.astro`
**Best for:** Blog posts, articles, text-heavy content.
**Imports:** `import ArticleLayout from '../../layouts/ArticleLayout.astro';`
**Props:**
- `content` (object): Frontmatter object `{ title, description, pubDate, ... }`.

---

## 🧩 UI Components (Building Blocks)

### Card Components
- **`GlassCard.astro`**: A premium glassmorphism card for features or benefits.
  - `import GlassCard from '../../components/ui/GlassCard.astro';`
  - Props: `title`, `description`, `icon` (emoji or char).
- **`DeepDiveCard.jsx`**: Interactive React card for detailed content.
  - `import DeepDiveCard from '../../components/ui/DeepDiveCard.jsx';`

### List & Text
- **`GoldenBullets.astro`**: A styled list with gold arrow icons.
  - `import GoldenBullets from '../../components/ui/GoldenBullets.astro';`
  - Props: `items` (Array of `{ icon, text }`), `columns` (1 or 2).
- **`BlueDivider.astro`**: A simple divider line.
- **`ScrollReveal.jsx`**: Text that reveals itself as you scroll.
- **`SmartHighlight.jsx`**: Text highlighting effect.

### Navigation & Action
- **`Navigation.astro`**: The main site navigation bar. (Included automatically in Layouts).
- **`PartyButton.jsx`**: A CTA button with confetti effects.
- **`ScalingSurvey.astro`**: The embedded Typeform/Survey component.
  - `import ScalingSurvey from '../../components/ui/ScalingSurvey.astro';`
  - Props: `webhookUrl` (optional).

---

## 🧮 Interactive Calculators (React)
*Note: Always use `client:only="react"` for these.*

- **`FunnelCalculator.jsx`**: Calculates traffic, conversion rates, and revenue.
- **`LTVCalculator.jsx`**: Calculates Lifetime Value.
- **`ROASCalculator.jsx`**: Calculates Return on Ad Spend.
- **`RoiCalculator.jsx`**: General ROI calculator.

**Usage:**
```astro
import FunnelCalculator from '../../components/calculators/FunnelCalculator';
<FunnelCalculator client:only="react" />
```

---

## ✨ Visuals & 3D Effects

- **`AtmosphereParticles.jsx`**: Background particle effect for Heros.
  - `import AtmosphereParticles from '../../components/3d/AtmosphereParticles';`
  - Usage: `<div class="hero-3d"><AtmosphereParticles client:only="react" /></div>`
- **`TechStackOrbit.astro`**: Orbiting icons animation.
- **`GrowthChart.astro` & `NeonChart.jsx`**: Visual charts representing growth.
- **`ROASVisual.astro`**: Specific visual for ROAS pages.

---

## 📦 Content Sections (Pre-built)

- **`DIYAISection.astro`**: A section that gives the user a prompt to use with ChatGPT/Claude.
  - `import DIYAISection from '../../components/content/DIYAISection.astro';`
  - Props: `serviceName`, `useCase`, `prompt`.
- **`ServiceSynergy.astro`**: A section showing how different services work together.
  - `import ServiceSynergy from '../../components/content/ServiceSynergy.astro';`

---

## 🎨 Global Styles & Utility Classes (`service-page.css`)

These classes are available globally when using `ServiceLayout`.

- **Containers**: `.container` (Responsive max-width wrapper).
- **Typography**: `h1`, `h2`, `h3`, `p`, `.subhead` (for hero subtitles).
- **Colors**: 
  - `.accent`, `.gold` (Gold Gradient Text).
  - Backgrounds: Body is `#000`. Glass cards use `rgba(255, 255, 255, 0.03)`.
- **Grids**: 
  - `.grid-3` (3 columns responsive).
  - `.grid-2-bias` (Left column larger).
  - `.process-flow` (Step-by-step layout).
- **Hero**: `.hero` (Flex centered, min-height 60vh).

---

## 📝 Example: Building a Basic Service Page

```astro
---
import ServiceLayout from '../../layouts/ServiceLayout.astro';
import AtmosphereParticles from '../../components/3d/AtmosphereParticles';
import GlassCard from '../../components/ui/GlassCard.astro';
---

<ServiceLayout 
  title="My New Service | Jumpstart Scaling" 
  description="This is an awesome new service."
>
  <!-- Hero Section -->
  <section class="hero">
    <div class="hero-3d"><AtmosphereParticles client:only="react" /></div>
    <div class="container">
      <h1>The Future of <span class="accent">Growth</span></h1>
      <p class="subhead">We build things that scale.</p>
    </div>
  </section>

  <!-- Features Section -->
  <section>
    <div class="container">
      <h2>Why Us?</h2>
      <div class="grid-3">
        <GlassCard title="Fast" description="Super fast." icon="⚡" />
        <GlassCard title="Cheap" description="Very affordable." icon="💰" />
        <GlassCard title="Good" description="High quality." icon="✨" />
      </div>
    </div>
  </section>
</ServiceLayout>
```
