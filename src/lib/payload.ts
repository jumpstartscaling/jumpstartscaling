/* src/lib/payload.ts */

// Define types for our content
export interface Page {
    id: string;
    title: string;
    slug: string;
    subtitle?: string;
    content: any; // Rich text structure usually
    metaDescription?: string;
    status: 'draft' | 'published';
    createdAt: string;
    updatedAt: string;
}

const PAYLOAD_URL = 'https://cms.jumpstartscaling.com';

export async function getPages(): Promise<Page[]> {
    try {
        const res = await fetch(`${PAYLOAD_URL}/api/pages?where[status][equals]=published`);
        if (!res.ok) throw new Error('Failed to fetch pages');
        const data = await res.json();
        return data.docs;
    } catch (e) {
        console.error('Error fetching pages:', e);
        return [];
    }
}

export async function getPageBySlug(slug: string): Promise<Page | null> {
    try {
        const res = await fetch(`${PAYLOAD_URL}/api/pages?where[slug][equals]=${slug}&depth=1`);
        if (!res.ok) throw new Error('Failed to fetch page');
        const data = await res.json();

        if (data.docs && data.docs.length > 0) {
            return data.docs[0];
        }
        return null;
    } catch (e) {
        console.error(`Error fetching page ${slug}:`, e);
        return null;
    }
}
