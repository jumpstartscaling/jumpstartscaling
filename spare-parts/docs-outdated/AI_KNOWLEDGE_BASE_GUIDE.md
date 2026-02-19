# AI Knowledge Base Builder Guide (JumpStart Scaling)

**Purpose**: This document serves as the guide for an AI Agent to build High-Ticket, SEO-optimized "Pillar Pages" for the JumpStart Scaling Knowledge Base.

---

## 🏗️ The 8-Section "Funnel-Local" Framework

Every high-ranking SEO page must follow this modular structure to ensure high engagement, local relevance, and high-ticket conversion.

### Section 1: The Sensory Hook (0-200 Words)
**Goal:** Reduce bounce rate, pass Core Web Vitals.
**Component:** `AtmosphereParticles` + `h1` with `.accent`.
**Content:** Start with a high-stakes scenario. NO "What is X?" intros.
**Example:** "While your competitors are burning cash on vanity metrics, you could be dominating the market."

### Section 2: The Anchor TOC
**Goal:** Navigation and User Experience.
**Component:** `StickyTOC` (Tailwind Sidebar).
**Content:** Jump links to "The Diagnosis", "The Math", "The Tactical Deep Dive".

### Section 3: The "Leak" Diagnosis (200-600 Words)
**Goal:** Address "Informational" intent. Pain-point identification.
**Component:** `ConversionWaterfall` (React Chart).
**Content:** Compare "Industry Average" (Failure) vs. "JumpStart Standard" (Success).
**Local Context Strategy:** "In hyper-competitive markets like **[City]**, a 1% leak is a $10k mistake."

### Section 4: The Interactive Proof (600-1000 Words)
**Goal:** The "Aha!" moment. Force interaction.
**Component:** `ScalePredictor` or `FunnelCalculator`.
**Content:** "Math is the only truth." explain the calculator results.

### Section 5: The Tactical Deep Dive (1000-1500 Words)
**Goal:** Semantic richness & Authority.
**Component:** `DeepDiveCard` + `GoldenBullets`.
**Content:** Technical breakdown (CAPI, CRM Routing, API Hooks).
**Keywords:** Attribution Analytics, ROI-Centric, CRM Automation.

### Section 6: The "DIY" Authority Gift (1500-1800 Words)
**Goal:** "Helpful Content" reward. Trust building.
**Component:** `DIYAISection`.
**Content:** A prompt or code snippet the user can use *right now*. "If you can't hire us, here is how to audit yourself."

### Section 7: The "Synergy" Offer (1800-2000 Words)
**Goal:** Cross-sell services.
**Component:** `ServiceSynergy`.
**Content:** Connect the current topic to another service tier using **Exact Prices**.
**Example:** "Great ads fail without our **$2,500 CRM Setup**."

### Section 8: The "Party" Close
**Goal:** Capture the lead.
**Component:** `PartyButton` + `ScalingSurvey`.
**Content:** No-risk CTA. "Audit My Strategy."

---

## 🌍 "Local-Global" SEO Strategy
**The Concept:** Use specific "Tier 1" cities to inject authority and relevance without building separate pages for each.

**Target City Array:**
*   **USA:** San Francisco (VC/SaaS), Austin (Tech Migration), Miami (Crypto/Finance), New York (Enterprise), Scottsdale (High-Ticket), Nashville (Healthcare).
*   **Global:** Dubai (Real Estate), London (FinTech), Singapore (Commerce), Zurich (Security).

**Implementation:**
The AI should randomly select or be assigned a city from this list to use as the "Context Anchor" for the article.
*   *Bad:* "We help businesses grow."
*   *Good:* "Whether you are fighting for market share in **Austin** or scaling a fintech in **London**, the math is the same."

---

## 🎨 Component Directives (React + Tailwind)

*   **Charts**: Use `Recharts` with `GoldGradient` stroke.
*   **Calculators**: Inputs must be `type="range"` with gold accents. Results use `font-mono` "Counter" animation.
*   **Images**: Use the `FeaturedImage` component logic (Grid-based SVG generation).

---

## 💻 `ArticleLayout.astro` (The Enforcer)

Always wrap SEO articles in this layout.

```astro
---
import ServiceLayout from './ServiceLayout.astro';
import AtmosphereParticles from '../components/3d/AtmosphereParticles';
import StickyTOC from '../components/ui/StickyTOC.astro';
import ServiceSynergy from '../components/content/ServiceSynergy.astro';

const { content } = Astro.props;
const { title, description, city = "Global Hubs", serviceTier } = content;
---

<ServiceLayout title={title} description={description}>
  <!-- Hero with Particles -->
  <section class="hero relative overflow-hidden min-h-[70vh] flex items-center">
    <div class="absolute inset-0 z-0"><AtmosphereParticles client:only="react" /></div>
    <div class="container relative z-10">
       <span class="text-gold font-mono uppercase tracking-widest">Market Insight: {city}</span>
       <h1 class="text-6xl font-black">{title}</h1>
    </div>
  </section>

  <div class="container grid grid-cols-1 lg:grid-cols-12 gap-12 py-20">
    <aside class="lg:col-span-3 hidden lg:block"><StickyTOC /></aside>
    <main class="lg:col-span-9 prose prose-invert prose-gold max-w-none">
       <slot /> 
       <!-- Global Footer CTA -->
       <div class="mt-20 pt-20 border-t border-white/10">
          <ServiceSynergy currentService={serviceTier} />
       </div>
    </main>
  </div>
</ServiceLayout>
```
