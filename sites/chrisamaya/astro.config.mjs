// @ts-check
import react from '@astrojs/react';
import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  integrations: [react()],
  vite: {
    server: {
      host: '0.0.0.0',
      allowedHosts: ['chrisamaya.work', 'www.chrisamaya.work', 'localhost', '127.0.0.1']
    },
    preview: {
      host: '0.0.0.0',
      allowedHosts: ['chrisamaya.work', 'www.chrisamaya.work', 'localhost', '127.0.0.1']
    }
  }
});
