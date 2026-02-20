import react from '@astrojs/react';
import node from '@astrojs/node';
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';
export default defineConfig({
  site: 'https://chrisamaya.work',
  base: '/',
  compressHTML: true,
  output: 'server',
  adapter: node({ mode: 'standalone' }),
  build: { inlineStylesheets: 'auto' },
  integrations: [react(), mdx(), sitemap({ changefreq: 'weekly', priority: 0.7, lastmod: new Date() })],
  vite: {
    plugins: [tailwindcss()],
    server: { allowedHosts: ['chrisamaya.work', 'www.chrisamaya.work', 'factory.jumpstartscaling.com', 'www.factory.jumpstartscaling.com', 'localhost', '127.0.0.1'] },
    build: { cssCodeSplit: true, rollupOptions: { output: { manualChunks: { 'react-vendor': ['react', 'react-dom'] } } } }
  }
});