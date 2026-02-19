# 🔄 React 19 Migration Guide - God Mode

## 🎯 Overview
This guide shows how to migrate EVERY component in God Mode from React 18 patterns to React 19 `useActionState` with Astro Actions.

---

## 📂 Components to Migrate

### **Priority 1: Forms & Data Submission (10 components)**

#### **1. `src/components/admin/ResourceMonitor.tsx`**
**Current:** Manual fetch with `useState` for pool stats  
**Migrate to:** `useActionState` with `actions.getDatabaseStats`

**Before:**
```tsx
const [stats, setStats] = useState(null);
const [loading, setLoading] = useState(false);

const fetchStats = async () => {
  setLoading(true);
  const res = await fetch('/api/god/pool/stats');
  setStats(await res.json());
  setLoading(false);
};
```

**After:**
```tsx
const [stats, refreshStats, isPending] = useActionState(
  experimental_withState(actions.getDatabaseStats),
  null
);
```

---

#### **2. `src/components/admin/FactoryHandshake.tsx`**
**Current:** Multiple `useState` for connection checks  
**Migrate to:** Single `useActionState` for system health

---

#### **3. `src/components/admin/Common/MasterReset.tsx`**
**Current:** Confirmation dialog with manual state  
**Migrate to:** Form action with confirmation

---

#### **4. `src/components/factory/ArticleCard.tsx`**
**Current:** onClick handlers for article actions  
**Migrate to:** Form buttons with `useActionState`

---

#### **5. `src/components/factory/BulkActions.tsx`**
**Current:** Checkbox selection + manual API calls  
**Migrate to:** Multi-select form with Actions

---

### **Priority 2: Admin Controls (15 components)**

All components in `src/components/admin/` that submit data:
- `CampaignManager.tsx`
- `SitesManager.tsx`
- `PagesManager.tsx`
- `ArticlesManager.tsx`
- `ImageTemplateEditor.tsx`
- `LocationBrowser.tsx`
- `DomainSetupGuide.tsx`

**Pattern:**
Replace all `fetch()` calls with `useActionState(actions.yourAction)`

---

## 🔧 Step-by-Step Migration

### **Step 1: Update Imports**
```tsx
// Remove
import { useState } from 'react';

// Add
import { useActionState } from 'react';
import { actions } from 'astro:actions';
import { experimental_withState } from '@astrojs/react/actions';
```

### **Step 2: Replace State Management**
```tsx
// OLD
const [data, setData] = useState(null);
const [loading, setLoading] = useState(false);
const [error, setError] = useState(null);

// NEW
const [state, formAction, isPending] = useActionState(
  experimental_withState(actions.yourAction),
  null
);
```

### **Step 3: Convert onClick to form action**
```tsx
// OLD
<button onClick={handleClick}>Submit</button>

// NEW
<form action={formAction}>
  <button type="submit" disabled={isPending}>
    {isPending ? 'Loading...' : 'Submit'}
  </button>
</form>
```

### **Step 4: Update Error/Success Display**
```tsx
// OLD
{error && <p>{error.message}</p>}
{data && <p>Success!</p>}

// NEW
{state?.error && <p>{state.error.message}</p>}
{state?.data && <p>Success!</p>}
```

---

## 📋 Migration Checklist

### **Core Components:**
- [ ] `ResourceMonitor.tsx` → Use `getDatabaseStats` action
- [ ] `FactoryHandshake.tsx` → Use system health action
- [ ] `SystemControl.tsx` → Use control actions
- [ ] `MasterReset.tsx` → Use reset action
- [ ] `CollectionTable.tsx` → Use CRUD actions

### **Factory Components:**
- [ ] `ArticleCard.tsx` → Use article actions
- [ ] `BulkActions.tsx` → Use bulk operations
- [ ] `CampaignManager.tsx` → Use campaign actions
- [ ] `KanbanBoard.tsx` → Convert drag/drop to actions
- [ ] `OptionsModal.tsx` → Use save action

### **Intelligence Components:**
- [ ] `AvatarCard.tsx` → Use avatar CRUD
- [ ] `EditModal.tsx` → Use update action
- [ ] `MetricsDashboard.tsx` → Use analytics action

### **Assembler Components:**
- [ ] `Pipeline.tsx` → Use pipeline actions
- [ ] `WorkflowBuilder.tsx` → Use workflow save
- [ ] `QualityChecker.tsx` → Use quality check action

### **Analytics Components:**
- [ ] `Charts/*.tsx` → Use data fetch actions
- [ ] `MetricCard.tsx` → Auto-refresh with actions

---

## 🚨 Breaking Changes to Watch

### **1. Event Handlers**
```tsx
// ❌ OLD - Won't work with Server Actions
const handleSubmit = (e: React.FormEvent) => {
  e.preventDefault();
  //  ...
};

// ✅ NEW - Use form action
<form action={formAction}>
```

### **2. Return Values**
```tsx
// ❌ OLD - Manual response parsing
const response = await fetch('/api/endpoint');
const data = await response.json();

// ✅ NEW - Automatic via useActionState
const [state] = useActionState(...);
// state.data is already parsed!
```

### **3. Loading States**
```tsx
// ❌ OLD - Manual tracking
const [isLoading, setIsLoading] = useState(false);

// ✅ NEW - Built-in
const [, , isPending] = useActionState(...);
```

---

## 🎯 Testing After Migration

### **1. Type Safety**
```bash
npm run typecheck
# Should pass with no errors
```

### **2. Runtime Testing**
```tsx
// Test form submission
cy.get('form').submit();
cy.get('[data-testid="success"]').should('exist');

// Test loading state
cy.get('button[type="submit"]').should('be.disabled');
```

### **3. Progressive Enhancement**
```html
<!-- Should work without JavaScript! -->
<form action="/api/actions/yourAction" method="POST">
  <input name="field" />
  <button type="submit">Submit</button>
</form>
```

---

## 📊 Migration Progress Tracker

| Component | Status | Priority | Estimated Time |
|-----------|--------|----------|----------------|
| ResourceMonitor.tsx | ❌ TODO | HIGH | 15 min |
| FactoryHandshake.tsx | ❌ TODO | HIGH | 20 min |
| SystemControl.tsx | ❌ TODO | HIGH | 15 min |
| MasterReset.tsx | ❌ TODO | MEDIUM | 10 min |
| ArticleCard.tsx | ❌ TODO | HIGH | 20 min |
| BulkActions.tsx | ❌ TODO | MEDIUM | 30 min |
| CampaignManager.tsx | ❌ TODO | HIGH | 25 min |
| CollectionTable.tsx | ❌ TODO | HIGH | 30 min |
| ImageTemplateEditor.tsx | ❌ TODO | MEDIUM | 20 min |
| KanbanBoard.tsx | ❌ TODO | LOW | 40 min |

**Total Estimated Time:** ~4-6 hours for all components

---

## 🔍 Common Patterns

### **Pattern 1: Simple Form**
```tsx
export function SimpleForm() {
  const [state, formAction, isPending] = useActionState(
    experimental_withState(actions.submit),
    null
  );

  return (
    <form action={formAction}>
      <input name="field" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Submitting...' : 'Submit'}
      </button>
      {state?.error && <p>{state.error.message}</p>}
    </form>
  );
}
```

### **Pattern 2: Complex Form with Multiple Fields**
```tsx
export function ComplexForm() {
  const [state, formAction, isPending] = useActionState(
    experimental_withState(actions.complexSubmit),
    null
  );

  return (
    <form action={formAction} className="space-y-4">
      <input name="name" required />
      <textarea name="description" />
      <select name="category">
        <option value="a">A</option>
        <option value="b">B</option>
      </select>
      
      <button type="submit" disabled={isPending}>
        {isPending ? 'Processing...' : 'Submit'}
      </button>
      
      {state?.data && <Success data={state.data} />}
      {state?.error && <Error error={state.error} />}
    </form>
  );
}
```

### **Pattern 3: Non-Form Actions (Buttons)**
```tsx
export function DeleteButton({ id }: { id: string }) {
  const [state, deleteAction, isPending] = useActionState(
    experimental_withState(actions.deleteItem),
    null
  );

  return (
    <form action={deleteAction}>
      <input type="hidden" name="id" value={id} />
      <button 
        type="submit" 
        disabled={isPending}
        className="text-red-600"
      >
        {isPending ? 'Deleting...' : '🗑️ Delete'}
      </button>
    </form>
  );
}
```

---

## ✅ Success Criteria

After migration, you should have:
- ✅ Zero `fetch()` calls in components
- ✅ Zero manual `useState` for loading/error
- ✅ All forms use `useActionState`
- ✅ Type safety from server to client
- ✅ Progressive enhancement (works without JS)
- ✅ Automatic error handling
- ✅ 40% less boilerplate code

---

**Start with Priority 1 components, then work through the rest systematically!** 🚀
