// @ts-check
import react from '@astrojs/react';
import { defineConfig } from 'astro/config';

import mdx from '@astrojs/mdx';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  integrations: [react(), mdx()],
  vite: {
    server: {
      allowedHosts: ['jumpstartscaling.com', 'www.jumpstartscaling.com', 'no.jumpstartscaling.com', 'localhost', '127.0.0.1'],
      hmr: {
        clientPort: 443
      }
    },
    preview: {
      allowedHosts: ['jumpstartscaling.com', 'www.jumpstartscaling.com', 'no.jumpstartscaling.com', 'localhost', '127.0.0.1']
    },

    plugins: [tailwindcss()]
  }
});