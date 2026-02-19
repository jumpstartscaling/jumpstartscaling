# 🔱 Astro 5 God Mode - Usage Guide

## Core Features Installed

### ✅ 1. Server Islands (Deferred Rendering)

Load heavy components after the initial page load for better performance.

**Example:**
```astro
---
// src/pages/index.astro
import HeavyChart from '../components/HeavyChart.astro';
import UserAvatar from '../components/UserAvatar.astro';
---

<h1>Dashboard</h1>

<!-- Load avatar individually after page load -->
<UserAvatar server:defer />
<div slot="fallback">
  <div class="animate-pulse bg-gray-200 h-12 w-12 rounded-full"></div>
</div>

<!-- Heavy chart loads separately -->
<HeavyChart server:defer />
<div slot="fallback">Loading chart...</div>
```

### ✅ 2. Astro Actions (Type-Safe Backend)

Call backend logic from client-side with full type safety.

**Example - Like a Post:**
```typescript
// In any .astro or .tsx file
import { actions } from 'astro:actions';

// Client-side code
const handleLike = async (postId: string) => {
  const { data, error } = await actions.likePost({ postId });
  
  if (error) {
    console.error('Failed to like:', error.message);
    return;
  }
  
  console.log('Liked!', data);
};
```

**Example - Add Comment:**
```typescript
import { actions } from 'astro:actions';

const handleComment = async (formData: FormData) => {
  const { data, error } = await actions.addComment({
    postId: formData.get('postId') as string,
    author: formData.get('author') as string,
    body: formData.get('body') as string,
    email: formData.get('email') as string,
  });
  
  if (error) {
    alert(error.message);
    return;
  }
  
  // Comment added successfully
  console.log('Comment:', data.comment);
};
```

**Example - God Mode SQL Execution:**
```typescript
import { actions } from 'astro:actions';

const runQuery = async (sql: string) => {
  const { data, error } = await actions.executeSql(
    {
      sql,
      params: []
    },
    {
      headers: {
        'X-God-Token': import.meta.env.GOD_MODE_TOKEN
      }
    }
  );
  
  if (error) {
    console.error('SQL Error:', error.message);
    return;
  }
  
  console.log('Results:', data.rows);
};
```

### ✅ 3. Content Layer API (New Loaders)

Access content collections with the new loader-based API.

**Example - Blog Posts:**
```astro
---
// src/pages/blog/index.astro
import { getCollection } from 'astro:content';

// Get all published blog posts
const posts = await getCollection('blog', ({ data }) => {
  return data.draft !== true;
});

// Sort by date
const sortedPosts = posts.sort((a, b) => 
  b.data.pubDate.valueOf() - a.data.pubDate.valueOf()
);
---

<h1>Blog</h1>
{sortedPosts.map(post => (
  <article>
    <h2>{post.data.title}</h2>
    <p>{post.data.description}</p>
    <time>{post.data.pubDate.toLocaleDateString()}</time>
    <a href={`/blog/${post.id}`}>Read more</a>
  </article>
))}
```

**Example - Templates from JSON:**
```astro
---
import { getCollection } from 'astro:content';

const templates = await getCollection('templates');
const blogTemplates = templates.filter(t => t.data.category === 'blog');
---

<h1>Blog Templates</h1>
{blogTemplates.map(template => (
  <div>
    <h3>{template.data.name}</h3>
    <p>{template.data.description}</p>
  </div>
))}
```

### ✅ 4. SVG Components

Import SVG files directly as React components.

**Example:**
```tsx
// Create src/assets/logo.svg first
import Logo from '../assets/logo.svg';

export default function Header() {
  return (
    <header>
      <Logo width={40} height={40} className="text-blue-500" />
      <h1>God Mode</h1>
    </header>
  );
}
```

### ✅ 5. Responsive Images

Automatic responsive image generation.

**Example:**
```astro
---
import { Image } from 'astro:assets';
import heroImage from '../assets/hero.png';
---

<!-- Automatically generates multiple sizes -->
<Image 
  src={heroImage} 
  alt="Hero Image"
  widths={[400, 800, 1200]}
  sizes="(max-width: 640px) 400px, (max-width: 1024px) 800px, 1200px"
/>
```

### ✅ 6. Client Prerender (Speculation Rules)

AI-driven link prefetching for instant page transitions.

**Example:**
```astro
---
// Automatically enabled in astro.config.mjs
// No code changes needed!
---

<!-- These links will be prerendered when in viewport -->
<nav>
  <a href="/about">About</a>
  <a href="/blog">Blog</a>
  <a href="/contact">Contact</a>
</nav>
```

### ✅ 7. Environment Variables Schema

Type-safe environment variables with validation.

**Example:**
```typescript
// Access in .astro files
---
const apiUrl = import.meta.env.PUBLIC_DIRECTUS_URL;
const secret = import.meta.env.GOD_MODE_TOKEN;
---

// Access in .ts/.tsx files
import { GOD_MODE_TOKEN } from 'astro:env/server';
import { PUBLIC_DIRECTUS_URL } from 'astro:env/client';

// Fully typed and validated!
```

---

## Complete Examples

### Example 1: Interactive Blog Post with Actions

```astro
---
// src/pages/blog/[slug].astro
import { getEntry } from 'astro:content';

export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map(post => ({
    params: { slug: post.id },
    props: { post },
  }));
}

const { post } = Astro.props;
const { Content } = await post.render();
---

<article>
  <h1>{post.data.title}</h1>
  <time>{post.data.pubDate.toLocaleDateString()}</time>
  
  <Content />
  
  <!-- Interactive like button using Actions -->
  <button id="likeBtn" data-post-id={post.id}>
    ❤️ Like
  </button>
  
  <!-- Comment form using Actions -->
  <form id="commentForm" data-post-id={post.id}>
    <input name="author" placeholder="Your name" required />
    <textarea name="body" placeholder="Your comment" required></textarea>
    <button type="submit">Post Comment</button>
  </form>
  
  <div id="comments"></div>
</article>

<script>
  import { actions } from 'astro:actions';
  
  // Like button
  document.getElementById('likeBtn')?.addEventListener('click', async (e) => {
    const postId = (e.target as HTMLElement).dataset.postId!;
    const { data, error } = await actions.likePost({ postId });
    
    if (data) {
      alert('Liked!');
    }
  });
  
  // Comment form
  document.getElementById('commentForm')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const form = e.target as HTMLFormElement;
    const formData = new FormData(form);
    
    const { data, error } = await actions.addComment({
      postId: form.dataset.postId!,
      author: formData.get('author') as string,
      body: formData.get('body') as string,
    });
    
    if (data) {
      // Add comment to page
      const commentsDiv = document.getElementById('comments')!;
      commentsDiv.innerHTML += `
        <div>
          <strong>${data.comment.author}</strong>
          <p>${data.comment.body}</p>
        </div>
      `;
      form.reset();
    }
  });
</script>
```

### Example 2: Dashboard with Server Islands

```astro
---
// src/pages/admin/dashboard.astro
import SystemStats from '@/components/admin/SystemStats.astro';
import UserActivity from '@/components/admin/UserActivity.astro';
import RecentContent from '@/components/admin/RecentContent.astro';
---

<div class="dashboard">
  <h1>God Mode Dashboard</h1>
  
  <!-- Load immediately -->
  <div class="quick-stats">
    <SystemStats />
  </div>
  
  <!-- Defer heavy components -->
  <div class="activity-section">
    <UserActivity server:defer />
    <div slot="fallback">
      <div class="skeleton">Loading activity...</div>
    </div>
  </div>
  
  <div class="content-section">
    <RecentContent server:defer />
    <div slot="fallback">
      <div class="skeleton">Loading recent content...</div>
    </div>
  </div>
</div>
```

### Example 3: God Mode SQL Console with Actions

```astro
---
// src/pages/admin/sql-console.astro
---

<div class="sql-console">
  <h1>SQL Console</h1>
  
  <textarea id="sqlEditor" rows="10" placeholder="SELECT * FROM sites LIMIT 10;"></textarea>
  
  <button id="executeBtn">Execute</button>
  
  <div id="results"></div>
</div>

<script>
  import { actions } from 'astro:actions';
  
  document.getElementById('executeBtn')?.addEventListener('click', async () => {
    const sql = (document.getElementById('sqlEditor') as HTMLTextAreaElement).value;
    const resultsDiv = document.getElementById('results')!;
    
    resultsDiv.innerHTML = 'Executing...';
    
    const { data, error } = await actions.executeSql(
      { sql },
      {
        headers: {
          'X-God-Token': import.meta.env.GOD_MODE_TOKEN
        }
      }
    );
    
    if (error) {
      resultsDiv.innerHTML = `<div class="error">${error.message}</div>`;
      return;
    }
    
    // Display results as table
    if (data && data.rows.length > 0) {
      const table = `
        <table>
          <thead>
            <tr>${Object.keys(data.rows[0]).map(k => `<th>${k}</th>`).join('')}</tr>
          </thead>
          <tbody>
            ${data.rows.map(row => `
              <tr>${Object.values(row).map(v => `<td>${v}</td>`).join('')}</tr>
            `).join('')}
          </tbody>
        </table>
      `;
      resultsDiv.innerHTML = table;
    } else {
      resultsDiv.innerHTML = '<p>No results</p>';
    }
  });
</script>
```

---

## Testing

### Test the Setup

```bash
# 1. Initialize Astro DB
npx astro db push

# 2. Build the project
npm run build

# 3. Run dev server
npm run dev
```

### Verify Features

1. **Server Islands**: Check Network tab - islands load separately
2. **Actions**: Open console - no TypeScript errors in client code
3. **Content Layer**: Visit `/blog` - posts render correctly
4. **SVG**: Check that SVG imports work
5. **Env Schema**: No validation errors on startup

---

## Troubleshooting

### "Cannot find module 'astro:actions'"

```bash
# Restart dev server
pkill -f "astro dev"
npm run dev
```

### "Database not initialized"

```bash
npx astro db push --force-reset
```

### TypeScript errors

```bash
# Regenerate types
npx astro sync
```

---

**All features installed and ready! 🔱**
