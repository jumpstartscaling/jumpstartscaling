# 📝 SEO Writer's Guide to Building Premium Interactive Articles

## 🎯 Overview

This guide explains how to create high-engagement, SEO-optimized articles using our premium visual components. No coding experience required—just follow the templates!

---

## 📋 Table of Contents

1. [Article Setup](#article-setup)
2. [Available Components](#available-components)
3. [Component Usage Guide](#component-usage-guide)
4. [SEO Best Practices](#seo-best-practices)
5. [Style Guidelines](#style-guidelines)
6. [Example Templates](#example-templates)

---

## 🚀 Article Setup

### Creating a New Article

**File Location:**
- Jumpstart articles: `sites/jumpstartscaling/src/pages/guide/your-article-name.mdx`
- Chris Amaya articles: `sites/chrisamaya/src/pages/guide/your-article-name.mdx`

**File Name Rules:**
- Use lowercase
- Use hyphens instead of spaces
- Example: `scaling-your-startup.mdx`, `building-mvp.mdx`

### Required Frontmatter (at top of file)

```mdx
---
layout: ../../layouts/ArticleLayout.astro
title: "Your Article Title"
description: "A compelling 150-160 character description for SEO"
publishDate: "2026-01-09"
image: "/images/article-name-og.jpg"
---
```

**Frontmatter Fields:**
- `layout`: Always use `../../layouts/ArticleLayout.astro` (don't change this)
- `title`: 50-60 characters, include primary keyword
- `description`: 150-160 characters, compelling meta description
- `publishDate`: Format YYYY-MM-DD
- `image`: Optional Open Graph image (1200x630px recommended)

---

## 🎨 Available Components

### Visual Components Library

| Component | Purpose | Best For |
|-----------|---------|----------|
| **ReadingProgress** | Progress bar at top | All articles (required) |
| **FloatingTech** | 3D sphere animation | Hero sections, tech articles |
| **SpaceScene** | Starfield background | Tech/startup content |
| **AtmosphereParticles** | Subtle particle effect | Background ambiance |
| **GrowthChart** | Animated line chart | Data, metrics, growth stories |
| **NeonChart** | Gradient area chart | Revenue, trends, forecasts |
| **SmartHighlight** | Underline/circle text | Emphasize key phrases |
| **ScrollReveal** | Word-by-word reveal | Important sections, quotes |
| **PartyButton** | Confetti CTA | Lead capture, downloads |
| **DeepDiveCard** | Collapsible sections | Technical details, deep dives |
| **RoiCalculator** | Interactive calculator | Lead engagement, value demos |
| **RiveMascot** | Animated mascot | Forms, playful interactions |
| **GoldDivider** | Section separator (Jumpstart) | Break up long sections |
| **BlueDivider** | Section separator (Chris) | Break up long sections |

---

## 📖 Component Usage Guide

### 1. ReadingProgress (Required for All Articles)

**What it does:** Shows a thin progress bar at the top that fills as readers scroll.

**How to use:**
```mdx
import ReadingProgress from '../../components/ui/ReadingProgress';

<ReadingProgress client:load />
```

**Settings:** None needed

**Best Practice:** Place at the very beginning of your article, right after imports.

---

### 2. FloatingTech (3D Animated Sphere)

**What it does:** Creates a glowing, rotating 3D sphere that adds premium feel.

**How to use:**
```mdx
import FloatingTech from '../../components/3d/FloatingTech';

<FloatingTech client:only="react" />
```

**Settings:** None needed

**Best Practice:**
- Use at the start of technical articles
- Use in hero sections
- Don't use more than once per article (performance)

**Writer's Note:** This component may take 2-3 seconds to load (WebGL). That's normal!

---

### 3. SpaceScene (Starfield Background)

**What it does:** Creates an animated starfield with a rotating wireframe box.

**How to use:**
```mdx
import SpaceScene from '../../components/3d/SpaceScene';

<SpaceScene client:only="react" />
```

**Settings:** None needed

**Best Practice:**
- Use in tech/innovation articles
- Use in startup scaling content
- Creates "looking up at the stars" feeling

---

### 4. GrowthChart (Animated Line Chart)

**What it does:** Shows an animated line chart with data points.

**How to use:**
```mdx
import GrowthChart from '../../components/charts/GrowthChart';

<GrowthChart client:visible />
```

**Settings:** None needed (uses default data)

**Default Data Shows:**
- Month 1: $5,000
- Month 2: $12,000
- Month 3: $25,000
- Month 4: $45,000
- Month 5: $75,000
- Month 6: $120,000

**Best Practice:**
- Use when discussing growth metrics
- Use when showing revenue progression
- Animates when scrolled into view

**Writer's Note:** Currently uses fixed data. To customize, tell the developer: "Update GrowthChart with these data points: [your data]"

---

### 5. NeonChart (Gradient Area Chart)

**What it does:** Shows a neon-styled chart with gradient fill.

**How to use:**
```mdx
import NeonChart from '../../components/charts/NeonChart';

<NeonChart client:visible />
```

**Settings:** None needed

**Default Data Shows:**
- Week 1: 400 units
- Week 2: 600 units
- Week 3: 800 units
- Week 4: 1200 units
- Week 5: 1600 units

**Best Practice:**
- Use for trend visualization
- Use for forecasting sections
- Creates premium "tech startup" vibe

---

### 6. SmartHighlight (Text Emphasis)

**What it does:** Adds hand-drawn style underlines or circles to text.

**How to use:**
```mdx
import SmartHighlight from '../../components/text/SmartHighlight';

This is <SmartHighlight text="super important" /> to remember.
```

**Settings:**
- `text`: The phrase to highlight (required)
- `color`: Optional (defaults to gold/blue based on site)

**Best Practice:**
- Use sparingly (2-3 times per article)
- Highlight key takeaways
- Use on short phrases (2-5 words)

**Examples:**
```mdx
<SmartHighlight text="unit economics" />
<SmartHighlight text="product-market fit" color="#D4AF37" />
```

---

### 7. ScrollReveal (Animated Text Reveal)

**What it does:** Reveals text word-by-word as you scroll, creating dramatic effect.

**How to use:**
```mdx
import ScrollReveal from '../../components/text/ScrollReveal';

<ScrollReveal text="This is a powerful statement that deserves dramatic reveal" client:visible />
```

**Settings:**
- `text`: The text to reveal (required)

**Best Practice:**
- Use for powerful statements
- Use for key statistics
- Use for memorable quotes
- Keep under 20 words
- Use once or twice per article

**Examples:**
```mdx
<ScrollReveal text="The companies that scale fastest aren't the ones with the most funding." client:visible />
```

---

### 8. PartyButton (Confetti CTA)

**What it does:** A button that shoots confetti when clicked. Creates dopamine hit!

**How to use:**
```mdx
import PartyButton from '../../components/ui/PartyButton';

<PartyButton text="Get the Free Guide" client:load />
```

**Settings:**
- `text`: Button label (required)

**Best Practice:**
- Use at end of articles for CTAs
- Use for lead magnets
- Use for important downloads
- Don't use more than once per article

**Examples:**
```mdx
<PartyButton text="Download the Scaling Playbook" client:load />
<PartyButton text="Start Your Free Trial" client:load />
```

---

### 9. DeepDiveCard (Collapsible Content)

**What it does:** Creates collapsible sections for technical details that don't overwhelm readers.

**How to use:**
```mdx
import DeepDiveCard from '../../components/ui/DeepDiveCard';

<DeepDiveCard title="Technical Deep Dive: The Math Behind It" client:visible>

Put your detailed technical content here.
Can include:
- Lists
- Code examples
- Formulas
- Technical explanations

</DeepDiveCard>
```

**Settings:**
- `title`: The header text (required)

**Best Practice:**
- Use for optional technical details
- Use for advanced tips
- Use for case study details
- Keeps articles scannable

---

### 10. RoiCalculator (Interactive Calculator)

**What it does:** Lets readers input numbers to calculate potential ROI/revenue.

**How to use:**
```mdx
import RoiCalculator from '../../components/interactive/RoiCalculator';

<RoiCalculator client:load />
```

**Settings:** None needed

**What It Shows:**
- Monthly Leads (slider: 0-1000)
- Conversion Rate (slider: 0-10%)
- Customer Value (input field)
- Calculated: Projected Monthly Revenue

**Best Practice:**
- Use mid-article to engage readers
- Use in articles about growth/scaling
- Increases time on page significantly

---

### 11. GoldDivider / BlueDivider (Section Breaks)

**What it does:** Creates a premium visual separator between sections.

**How to use:**

**For Jumpstart Scaling:**
```mdx
import GoldDivider from '../../components/ui/GoldDivider';

<GoldDivider />
```

**For Chris Amaya:**
```mdx
import BlueDivider from '../../components/ui/BlueDivider';

<BlueDivider />
```

**Settings:** None needed

**Best Practice:**
- Use between major sections
- Use instead of `---` markdown dividers
- Use 2-4 times per long article
- Creates visual breathing room

---

## ✍️ SEO Best Practices

### Title Optimization

**Structure:**
```
[Primary Keyword] - [Benefit/Hook] | Site Name
```

**Examples:**
- "Scaling Your Startup - The Complete 2026 Guide | Jumpstart Scaling"
- "Unit Economics Made Simple - Calculate Your Path to Profitability | Jumpstart Scaling"

**Rules:**
- 50-60 characters total
- Include primary keyword early
- Make it click-worthy
- Avoid clickbait

### Description Optimization

**Structure:**
```
[Hook/Benefit]. [Supporting detail]. [Call to action].
```

**Examples:**
- "Learn how top startups scale from $0 to $10M ARR. Data-driven strategies from 100+ successful companies. Interactive tools included."
- "Master unit economics with our step-by-step framework. Calculate CAC, LTV, and payback periods. See your scaling potential now."

**Rules:**
- 150-160 characters
- Include primary keyword
- Include secondary keyword if possible
- End with action/benefit

### Header Structure (H1, H2, H3)

**Rules:**
- **ONE H1** per article (auto-generated from title)
- Use H2 for main sections
- Use H3 for subsections
- Include keywords in headers naturally
- Make headers scannable

**Example Structure:**
```mdx
# Your Title (H1 - automatic)

## The Challenge (H2)
### Why Most Startups Fail (H3)
###  The Hidden Metrics (H3)

## The Framework (H2)
### Step 1: Validate PMF (H3)
### Step 2: Optimize Unit Economics (H3)

## The Results (H2)
```

### Internal Linking

**Best Practice:**
```mdx
Learn more about [unit economics](/ guide/unit-economics-guide) in our detailed guide.
```

**Where to Link:**
- Other relevant articles
- Homepage
- Lead magnets
- Tools/calculators

**Link 2-5 times per article to:**
- Related content
- Conversion goals
- High-value pages

### Image Optimization

**Requirements:**
- Format: WebP or JPEG
- Size: Under 200KB
- Dimensions: 1200x630px for OG images
- Alt text: Always include descriptive alt text

**Alt Text Example:**
```mdx
![Graph showing startup revenue growth from $5K to $120K over 6 months](/ images/growth-chart.webp)
```

---

## 🎨 Style Guidelines

### Jumpstart Scaling (Black/Gold)

**Tone:**
- Authoritative but accessible
- Data-driven
- Action-oriented
- No fluff

**Visual Style:**
- Use **bold** for key points
- Use gold highlights sparingly
- Use charts for data
- Use calculators for engagement

**Recommended Components:**
- GrowthChart
- RoiCalculator
- SmartHighlight
- PartyButton (for CTAs)

**Word Count:**
- Minimum: 1,500 words
- Sweet spot: 2,000-3,000 words
- Maximum: 5,000 words

### Chris Amaya (White/Blue)

**Tone:**
- Professional
- Technical but clear
- Thoughtful
- Detail-oriented

**Visual Style:**
- Use `code snippets` for technical terms
- Use blockquotes for important notes
- Use lists extensively
- Use deep dive cards for advanced topics

**Recommended Components:**
- DeepDiveCard
- BlueDivider
- Code blocks (markdown)
- ScrollReveal (for key insights)

**Word Count:**
- Minimum: 1,000 words
- Sweet spot: 1,500-2,500 words
- Technical depth over length

---

## 📚 Example Templates

### Template 1: Growth/Scaling Article (Jumpstart)

```mdx
---
layout: ../../layouts/ArticleLayout.astro
title: "How to Scale from $0 to $1M ARR in 12 Months"
description: "The exact framework used by 50+ startups to reach $1M ARR. Includes interactive calculator and real examples."
publishDate: "2026-01-09"
---

import ReadingProgress from '../../components/ui/ReadingProgress';
import FloatingTech from '../../components/3d/FloatingTech';
import SmartHighlight from '../../components/text/SmartHighlight';
import GrowthChart from '../../components/charts/GrowthChart';
import RoiCalculator from '../../components/interactive/RoiCalculator';
import GoldDivider from '../../components/ui/GoldDivider';
import PartyButton from '../../components/ui/PartyButton';

<ReadingProgress client:load />

<FloatingTech client:only="react" />

# How to Scale from $0 to $1M ARR in 12 Months

Most founders think scaling requires massive funding. They're wrong.

The companies that scale fastest master <SmartHighlight text="unit economics first" />, then pour fuel on the fire.

This is the exact framework that got 50+ startups to $1M ARR in under 12 months.

<GoldDivider />

## The Brutal Truth About Scaling

95% of startups that raise funding never hit $1M ARR. Why?

They scale before they're ready.

Here's what actually happens:

<GrowthChart client:visible />

See that curve? That's not luck. That's deliberately optimized growth.

<GoldDivider />

## Calculate Your Scaling Potential

Don't just take my word for it. See what your numbers could look like:

<RoiCalculator client:load />

If that projected revenue excites you, keep reading.

<GoldDivider />

## The Framework: 4 Pillars

### 1. Product-Market Fit Validation

[Your content here...]

### 2. Unit Economics Optimization

[Your content here...]

### 3. Channel Efficiency

[Your content here...]

### 4. Systematic Scaling

[Your content here...]

<GoldDivider />

## Ready to Start?

Get the complete scaling playbook with frameworks, templates, and calculators:

<PartyButton text="Download the Free Playbook" client:load />

```

### Template 2: Technical Guide (Chris Amaya)

```mdx
---
layout: ../../layouts/ArticleLayout.astro
title: "Building Scalable APIs with Django REST Framework"
description: "A comprehensive guide to architecting REST APIs that handle millions of requests. Includes code examples and best practices."
publishDate: "2026-01-09"
---

import ReadingProgress from '../../components/ui/ReadingProgress';
import BlueDivider from '../../components/ui/BlueDivider';
import DeepDiveCard from '../../components/ui/DeepDiveCard';
import ScrollReveal from '../../components/text/ScrollReveal';

<ReadingProgress client:load />

# Building Scalable APIs with Django REST Framework

<ScrollReveal text="The best API is the one that gets out of the way." client:visible />

This guide covers everything you need to build production-grade APIs using Django REST Framework.

<BlueDivider />

## Architecture Overview

[Your content here...]

### Core Principles

1. **Stateless design**
2. **Proper authentication**
3. **Rate limiting from day one**

<BlueDivider />

## Implementation Details

Here's the basic structure:

```python
from rest_framework import serializers, viewsets
from .models import YourModel

class YourSerializer(serializers.ModelSerializer):
    class Meta:
        model = YourModel
        fields = '__all__'
```

<DeepDiveCard title="Advanced: Custom Pagination" client:visible>

For high-traffic APIs, implement cursor-based pagination:

```python
from rest_framework.pagination import CursorPagination

class CustomPagination(CursorPagination):
    page_size = 100
    ordering = '-created_at'
```

This handles millions of records efficiently.

</DeepDiveCard>

<BlueDivider />

## Performance Optimization

[Your content here...]

```

---

## 🔧 Working with the Developer

### Requesting Custom Data for Charts

**Template for developer:**
```
"Update [GrowthChart/NeonChart] with these data points:
- Point 1: [value]
- Point 2: [value]
- Point 3: [value]
- Label: [x-axis label]"
```

### Requesting New Components

**Template for developer:**
```
"Create a [type] component that:
- Does [specific function]
- Shows [specific data]
- Has settings for [customizable elements]
- Style: [gold/blue/neutral]"
```

### Requesting Component Modifications

**Template for developer:**
```
"Modify [ComponentName]:
- Change [element] from [current] to [desired]
- Add setting for [new option]
- Make [element] clickable/interactive"
```

---

## ✅ Pre-Publication Checklist

Before submitting an article:

- [ ] Frontmatter complete (title, description, date)
- [ ] Reading Progress component included
- [ ] Title is 50-60 characters
- [  ] Description is 150-160 characters
- [ ] Headers use H2 and H3 properly
- [ ] At least one visual component included
- [ ] Internal links to 2-3 related pages
- [ ] CTA with PartyButton at end
- [ ] Images have alt text
- [ ] No spelling/grammar errors
- [ ] Article is 1,500+ words (Jumpstart) or 1,000+ words (Chris)
- [ ] Keywords used naturally throughout

---

## 📊 Component Load Times Reference

**For writer's planning:**

| Component | Load Time | Performance Impact |
|-----------|-----------|-------------------|
| ReadingProgress | Instant | None |
| SmartHighlight | Instant | None |
| GoldDivider | Instant | None |
| PartyButton | Instant | None |
| GrowthChart | <  1 second | Low |
| NeonChart | < 1 second | Low |
| RoiCalculator | < 1 second | Low |
| DeepDiveCard | < 1 second | Low |
| FloatingTech | 2-3 seconds | Medium |
| SpaceScene | 2-3 seconds | Medium |
| AtmosphereParticles | 2-3 seconds | Medium |

**Best Practice:**
- Use max 1-2 3D components per article
- 3D components may show loading briefly (this is normal!)

---

## 🎯 Final Tips for SEO Writers

1. **Start with the reader in mind** - Write for humans first, search engines second
2. **Use components strategically** - They increase engagement but don't overuse
3. **Data wins** - Include stats, charts, calculators when possible
4. **Scannable format** - Short paragraphs, lots of headers, bullet points
5. **Clear CTAs** - Every article should have a clear next step
6. **Internal links** - Link to other valuable content
7. **Mobile-first** - Most readers are on mobile, keep it simple
8. **Test components** - Preview your article before publishing

---

**Questions? Ask the developer to add to this guide!**

Last Updated: 2026-01-09  
Version: 1.0
