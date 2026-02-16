import { defineConfig } from 'astro/config';
import node from '@astrojs/node';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import partytown from '@astrojs/partytown';
import compress from 'astro-compress';
import robotsTxt from 'astro-robots-txt';
import icon from 'astro-icon';
import { VitePWA } from '@vite-pwa/astro';
import webVitals from '@astrojs/web-vitals';

/**
 * PRODUCTION CONFIGURATION
 * 
 * This config is optimized for production deployment with:
 * - Maximum compression
 * - Security headers
 * - Performance optimizations
 * - CDN-friendly caching
 * - Error tracking (Sentry)
 * 
 * Deploy with: NODE_ENV=production npm run build
 */

export default defineConfig({
    site: process.env.SITE_URL || 'https://spark.jumpstartscaling.com',
    output: 'server',

    // Production prefetching strategy
    prefetch: {
        prefetchAll: false, // Only prefetch explicit links in production
        defaultStrategy: 'hover' // Prefetch on hover for better UX
    },

    // Node adapter with production settings
    adapter: node({
        mode: 'standalone'
    }),

    // Optimized image handling
    image: {
        service: {
            entrypoint: 'astro/assets/services/sharp'
        },
        domains: ['office.jumpstartscaling.com', 'spark.jumpstartscaling.com'],
        remotePatterns: [
            {
                protocol: 'https',
                hostname: '**.jumpstartscaling.com',
            },
        ],
    },

    // Production integrations
    integrations: [
        // React with production optimizations
        react({
            experimentalReactChildren: true
        }),

        // Tailwind
        tailwind({
            applyBaseStyles: true,
        }),

        // MDX
        mdx({
            optimize: true,
        }),

        // Sitemap with custom configuration
        sitemap({
            filter: (page) => {
                // Exclude admin pages and API routes
                return !page.includes('/admin/') &&
                    !page.includes('/api/') &&
                    !page.includes('/_');
            },
            changefreq: 'weekly',
            priority: 0.7,
            lastmod: new Date(),
            customPages: [
                'https://spark.jumpstartscaling.com/',
            ],
        }),

        // Robots.txt for production
        robotsTxt({
            sitemap: [
                'https://spark.jumpstartscaling.com/sitemap-index.xml',
            ],
            policy: [
                {
                    userAgent: '*',
                    allow: '/',
                    disallow: ['/admin/', '/api/', '/_*'],
                    crawlDelay: 10,
                },
                {
                    userAgent: 'Googlebot',
                    allow: '/',
                    disallow: ['/admin/', '/api/'],
                },
            ],
            host: 'https://spark.jumpstartscaling.com',
        }),

        // Icon optimization
        icon({
            include: {
                lucide: ['*'],
            },
        }),

        // Partytown for third-party scripts
        partytown({
            config: {
                forward: ['dataLayer.push', 'gtag'],
                debug: false, // Disable debug in production
            },
        }),

        // Maximum compression for production
        compress({
            CSS: {
                csso: {
                    restructure: true,
                    forceMediaMerge: true,
                },
            },
            HTML: {
                'html-minifier-terser': {
                    removeAttributeQuotes: false,
                    removeComments: true,
                    collapseWhitespace: true,
                    conservativeCollapse: true,
                    minifyCSS: true,
                    minifyJS: true,
                },
            },
            Image: {
                webp: {
                    quality: 85,
                },
                avif: {
                    quality: 80,
                },
                jpg: {
                    quality: 85,
                    mozjpeg: true,
                },
                png

                    : {
                    quality: 85,
                },
            },
            JavaScript: {
                terser: {
                    compress: {
                        drop_console: true, // Remove console.log in production
                        drop_debugger: true,
                        pure_funcs: ['console.log', 'console.info'],
                    },
                },
            },
            SVG: {
                svgo: {
                    plugins: [
                        'removeViewBox',
                        'cleanupIDs',
                        'removeUselessDefs',
                    ],
                },
            },
        }),

        // PWA with production manifest
        VitePWA({
            registerType: 'autoUpdate',
            includeAssets: ['favicon.ico', 'robots.txt', 'icon-*.png'],
            manifest: {
                name: 'God Mode - Content Factory',
                short_name: 'God Mode',
                description: 'Advanced multi-site content generation and management platform',
                theme_color: '#000000',
                background_color: '#000000',
                display: 'standalone',
                scope: '/',
                start_url: '/admin',
                orientation: 'any',
                icons: [
                    {
                        src: '/icon-192.png',
                        sizes: '192x192',
                        type: 'image/png',
                        purpose: 'any maskable',
                    },
                    {
                        src: '/icon-512.png',
                        sizes: '512x512',
                        type: 'image/png',
                        purpose: 'any maskable',
                    },
                ],
            },
            workbox: {
                globPatterns: ['**/*.{js,css,html,svg,png,ico,txt,woff,woff2}'],
                runtimeCaching: [
                    {
                        urlPattern: /^https:\/\/office\.jumpstartscaling\.com\/.*/i,
                        handler: 'CacheFirst',
                        options: {
                            cacheName: 'directus-cache',
                            expiration: {
                                maxEntries: 50,
                                maxAgeSeconds: 60 * 60 * 24 * 30, // 30 days
                            },
                            cacheableResponse: {
                                statuses: [0, 200],
                            },
                        },
                    },
                    {
                        urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
                        handler: 'CacheFirst',
                        options: {
                            cacheName: 'google-fonts-cache',
                            expiration: {
                                maxEntries: 10,
                                maxAgeSeconds: 60 * 60 * 24 * 365, // 1 year
                            },
                        },
                    },
                    {
                        urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp|avif)$/,
                        handler: 'CacheFirst',
                        options: {
                            cacheName: 'image-cache',
                            expiration: {
                                maxEntries: 100,
                                maxAgeSeconds: 60 * 60 * 24 * 30, // 30 days
                            },
                        },
                    },
                ],
                cleanupOutdatedCaches: true,
                skipWaiting: true,
                clientsClaim: true,
            },
        }),

        // Web Vitals
        webVitals(),
    ],

    // Production Vite configuration
    vite: {
        // SSR configuration
        ssr: {
            noExternal: ['path-to-regexp'],
            external: ['sharp', 'pg-native'],
        },

        // Production build optimization
        build: {
            target: 'esnext',
            minify: 'terser',
            terserOptions: {
                compress: {
                    drop_console: true,
                    drop_debugger: true,
                    pure_funcs: ['console.log'],
                    passes: 2,
                },
                mangle: true,
                format: {
                    comments: false,
                },
            },
            rollupOptions: {
                output: {
                    // Optimized chunk splitting
                    manualChunks: (id) => {
                        // Vendor chunks
                        if (id.includes('node_modules')) {
                            if (id.includes('react') || id.includes('react-dom')) {
                                return 'react-vendor';
                            }
                            if (id.includes('@tanstack')) {
                                return 'tanstack';
                            }
                            if (id.includes('@radix-ui')) {
                                return 'ui';
                            }
                            if (id.includes('recharts') || id.includes('@tremor')) {
                                return 'charts';
                            }
                            if (id.includes('leaflet')) {
                                return 'maps';
                            }
                            if (id.includes('lucide')) {
                                return 'icons';
                            }
                            return 'vendor';
                        }
                    },
                    // Hashed filenames for cache busting
                    entryFileNames: 'entry.[hash].js',
                    chunkFileNames: 'chunks/[name].[hash].js',
                    assetFileNames: 'assets/[name].[hash][extname]',
                },
            },
            chunkSizeWarningLimit: 1000,
            cssCodeSplit: true,
            sourcemap: false, // Disable source maps in production
            reportCompressedSize: false, // Faster builds
        },

        // Production optimizations
        optimizeDeps: {
            exclude: ['@astrojs/markdown-remark', 'sharp'],
            include: ['react', 'react-dom'],
            esbuildOptions: {
                target: 'esnext',
            },
        },

        // Production mode settings
        define: {
            'process.env.NODE_ENV': JSON.stringify('production'),
        },

        // No proxy in production (uses actual URLs)
        server: undefined,
    },

    // Markdown configuration
    markdown: {
        shikiConfig: {
            theme: 'github-dark',
            wrap: true,
            langs: [],
        },
        remarkPlugins: [],
        rehypePlugins: [],
    },

    // Security and performance
    experimental: {
        contentCollectionCache: true,
    },

    // Production server configuration
    server: {
        host: '0.0.0.0',
        port: 4321,
        headers: {
            'X-Frame-Options': 'SAMEORIGIN',
            'X-Content-Type-Options': 'nosniff',
            'Referrer-Policy': 'strict-origin-when-cross-origin',
            'Permissions-Policy': 'camera=(), microphone=(), geolocation=()',
        },
    },
});
