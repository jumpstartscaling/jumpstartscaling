# 🔱 CONTENT BLOCKS MANUAL IMPORT GUIDE

##  BLOCKER: Directus Auto-Timestamps

The Directus API cannot be used to programmatically create content_blocks because the `date_created` and `created_at` fields are auto-managed by Directus and cause 500 errors when included in API requests.

**Solution:** You must create these manually in the Directus UI or use direct SQL injection.

---

## ✅ OPTION 1: SQL Direct Injection (Recommended)

Run the SQL file directly on your database:

```bash
psql $DATABASE_URL -f god_architect_local/content_blocks_inject.sql
```

This will inject all 27 content blocks across the 3 sites.

---

## ✅ OPTION 2: Manual Creation in Directus UI

### Jumpstart Scaling (9 blocks):

**Go to:** Content → Content Blocks → Create New

For each block below, create a new entry with:

| Field | Value |
|-------|-------|
| **Site** | Jumpstart Scaling |
| **Block Type** | spintax_template |
| **Status** | published |

#### Block 1: Main Headline (h1)
- **Name:** Main Headline
- **Content:** `{Zapier & Digital Agencies|Overpriced SaaS Consultants|Legacy Marketing Firms} Terrified You'll Discover How To Have A Constant Flow Of {Exclusive pSEO Traffic|High-Margin Leads|Automated Revenue} Without Them`

#### Block 2: Introduction (intro)
- **Name:** Introduction
- **Content:** `{For any growing business, consistent lead flow in {{location}} is the foundation of scaling and long-term profitability.|In the competitive market of {{geo_cluster}}, securing a predictable pipeline of high-intent prospects is the only way to survive.|Scaling an agency requires a shift from manual outreach to automated, self-sustaining systems near {{landmarks}}.} {Escaping the 'Zapier Tax' and legacy agency dependence is the key to reclaiming your margins.|By leveraging Spark and n8n, you can bypass the high costs of traditional lead generation in {{zip_code}}.|Our framework allows you to dominate search results without the bloat of a 10-person marketing team.}`

#### Block 3: Philosophy (philosophy)  
- **Name:** Philosophy
- **Content:** `{Before you ramp up your ad spend, you must adopt a system-first operational mindset for {{location}}.|Successful scaling relies on systematizing trust and visibility through programmatic architecture.|You cannot achieve exponential growth using linear, manual processes that cap your output near {{landmarks}}.} {The goal is to attract high-intent leads who are pre-qualified for your high-ticket offers.|We focus on creating a self-reinforcing loop where every new page attracts more data and more conversions.|Spark ensures your infrastructure is an asset that grows in value rather than a monthly expense.}`

#### Block 4: Reciprocity (reciprocity)
- **Name:** Reciprocity
- **Content:** `{Providing massive value upfront is the core of the Spark philosophy, which is why we offer free ROI calculators for businesses in {{location}}.|We believe in the rule of reciprocity, giving prospective clients high-level pSEO audits before ever asking for a contract.|Giving first allows you to qualify enterprise leads near {{landmarks}} without spending a single dime on manual discovery calls.} {By offering a free architectural health check, you create an immediate sense of obligation and authority in {{geo_cluster}}.|This low-risk value exchange is exactly what converts cold traffic into high-ticket scaling partners.|Our system automates the delivery of these lead magnets across your entire multi-site network.}`

#### Block 5: Cold Outreach (cold_outreach)
- **Name:** Cold Outreach
- **Content:** `{Cold outreach in {{location}} is no longer a numbers game; it is a data-mapping game that requires surgical precision.|With Spark, we use precision targeting to reach C-level decision-makers near {{landmarks}} at exactly the right time.|Our system identifies high-intent accounts by tracking technographic shifts and budget cycles in {{geo_cluster}}.} {Stop sending generic spam and start sending personalized, research-backed value propositions to your target accounts.|We automate the sequence enrollment based on site-specific data and industry-leading triggers managed in our DB.|This ensures your outreach feels like a tailored consultation rather than a cold solicitation.}`

#### Block 6: Automation (automation)
- **Name:** Automation  
- **Content:** `{The 'Zapier Tax' is a silent killer of agency margins in {{location}} that we eliminate by migrating your logic to n8n.|We refactor your expensive, linear Zaps into robust, multi-branching n8n workflows that handle complex scaling.|Our automation architecture allows you to handle millions of tasks near {{landmarks}} for a fraction of the cost.} {n8n acts as the central nervous system of your Spark network, syncing data across every domain.|By self-hosting your logic, you retain 100% data ownership and security for your scaling business.|We turn your automation spaghetti into clean, modular nodes that are easy to debug.}`

#### Block 7: Content Marketing (content_marketing)
- **Name:** Content Marketing
- **Content:** `{Content marketing in {{location}} is about establishing unshakeable authority over your competitors.|For high-growth agencies in {{geo_cluster}}, your content serves as the ultimate trust signal for high-intent founders.|Every blog post and case study is a high-performance asset designed to convert leads near {{landmarks}}.} {By publishing detailed guides on pSEO and n8n, you answer the technical objections typically found in long sales cycles.|Short-form videos showcasing Spark-based deployments provide the social proof needed to close elite enterprise deals.|Every piece of content is optimized for the {{zip_code}} market to ensure maximum visibility.}`

#### Block 8: Implementation (implementation)
- **Name:** Implementation
- **Content:** `{The path to a high-authority digital presence starts with a clear roadmap tailored to your {{location}} market.|We begin by defining your ideal high-margin customer profile to ensure our architecture hits the mark.|My implementation checklist focuses on moving you from a legacy monolith to a decoupled Spark system near {{landmarks}}.} {We prioritize the optimization of your {{business_name}} and local signals to boost your 'near me' ranking power.|By deploying n8n automation first, we free up your time to focus on closing the new pipeline.|The result is a self-sustaining customer acquisition engine that makes your brand the dominant voice.}`

#### Block 9: Conclusion (conclusion)
- **Name:** Conclusion
- **Content:** `{Sustainable growth in {{location}} is not a mystery; it is a matter of deploying superior infrastructure like Spark.|Following these principles creates a self-sustaining lead generation machine primed for expansion near {{landmarks}}.|The choice is simple: continue renting your audience from platforms or start owning your own architecture.} {Start your journey today by auditing your current stack and identifying your biggest operational bottlenecks.|We are ready to help you ignite the Spark engine and dominate your global or local search market.|Click below to download your 90-day pipeline accelerator and start scaling your empire.}`

---

### Complete the same process for:
- **Christopher Amaya** (9 blocks - see `content_blocks_inject.sql` for exact content)
- **Masta Codes** (9 blocks - see `content_blocks_inject.sql` for exact content)

---

## 📊 VERIFICATION

After manual creation or SQL injection:

```sql
SELECT  
    s.name as site_name,
    COUNT(cb.id) as content_blocks
FROM sites s
LEFT JOIN content_blocks cb ON cb.site_id = s.id
WHERE s.id IN (
    '54321789-0000-0000-0000-000000000000',
    '54321789-0000-0000-0000-000000000001',
    '54321789-0000-0000-0000-000000000002'
)
GROUP BY s.name;
```

**Expected:**
- Jumpstart Scaling: 9 blocks
- Christopher Amaya: 9 blocks  
- Masta Codes: 9 blocks

---

**Due to Directus auto-timestamp limitations, programmatic API creation is blocked. Use SQL injection or manual UI creation.** 🔱✨
