#!/bin/bash
# 🚀 Proper Payload Multi-Tenant Setup

set -e

SERVER="opc@193.122.168.215"
APP_DIR="payload-multitenant"

echo "🧹 Removing old incomplete installation..."
ssh -i ~/.ssh/id_rsa $SERVER "rm -rf /home/opc/$APP_DIR"

echo "📦 Creating proper Payload Next.js app structure..."
ssh -i ~/.ssh/id_rsa $SERVER << 'EOFSETUP'
cd /home/opc
mkdir -p payload-multitenant
cd payload-multitenant

# Create package.json
cat > package.json << 'EOFPACKAGE'
{
  "name": "payload-multitenant",
  "version": "1.0.0",
  "description": "Multi-tenant CMS for JumpStart Scaling",
  "scripts": {
    "dev": "cross-env NODE_OPTIONS=\"${NODE_OPTIONS} --no-deprecation\" next dev",
    "build": "cross-env NODE_OPTIONS=\"${NODE_OPTIONS} --no-deprecation\" next build",
    "start": "cross-env NODE_OPTIONS=\"${NODE_OPTIONS} --no-deprecation\" next start",
    "lint": "cross-env NODE_OPTIONS=\"${NODE_OPTIONS} --no-deprecation\" next lint",
    "generate:types": "payload generate:types",
    "payload": "payload"
  },
  "dependencies": {
    "@payloadcms/db-postgres": "^3.9.1",
    "@payloadcms/next": "^3.9.1",
    "@payloadcms/richtext-lexical": "^3.9.1",
    "@payloadcms/translations": "^3.9.1",
    "@payloadcms/ui": "^3.9.1",
    "cross-env": "^7.0.3",
    "graphql": "^16.9.0",
    "next": "15.1.4",
    "payload": "^3.9.1",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "sharp": "^0.33.5"
  },
  "devDependencies": {
    "@types/node": "^22.10.2",
    "@types/react": "^19.0.6",
    "@types/react-dom": "^19.0.2",
    "typescript": "^5.7.2"
  },
  "engines": {
    "node": "^18.20.2 || >=20.9.0"
  }
}
EOFPACKAGE

# Create tsconfig.json
cat > tsconfig.json << 'EOFTS'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": false,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOFTS

# Create .gitignore  
cat > .gitignore << 'EOFGIT'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Next.js
.next/
out/
build/
dist/

# Misc
.DS_Store
*.pem

# Debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Local env files
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# TypeScript
*.tsbuildinfo
next-env.d.ts

# Payload
media/
EOFGIT

# Create directory structure
mkdir -p src/app
mkdir -p src/collections
mkdir -p public

# Create Next.js config
cat > next.config.ts << 'EOFNEXT'
import type { NextConfig } from 'next'
import { withPayload } from '@payloadcms/next/withPayload'

const nextConfig: NextConfig = {
  experimental: {
    reactCompiler: false,
  },
}

export default withPayload(nextConfig)
EOFNEXT

# Create environment file
cat > .env << 'EOFENV'
# Database
DATABASE_URI=postgres://postgres:password@localhost:5432/payload

# Payload
PAYLOAD_SECRET=your-secret-key-change-this-to-something-secure
PAYLOAD_CONFIG_PATH=src/payload.config.ts

# Server
NEXT_PUBLIC_SERVER_URL=http://localhost:3000
PORT=3000
EOFENV

# Create Payload config
cat > src/payload.config.ts << 'EOFCONFIG'
import { buildConfig } from 'payload'
import { postgresAdapter } from '@payloadcms/db-postgres'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import path from 'path'
import { fileURLToPath } from 'url'
import sharp from 'sharp'

import { Users } from './collections/Users'
import { Tenants } from './collections/Tenants'
import { Pages } from './collections/Pages'
import { Media } from './collections/Media'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

export default buildConfig({
  admin: {
    user: 'users',
    meta: {
title: 'JumpStart Scaling CMS',
      favicon: '/favicon.ico',
    },
  },
  collections: [Users, Tenants, Pages, Media],
  editor: lexicalEditor({}),
  secret: process.env.PAYLOAD_SECRET || 'fallback-secret',
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  db: postgresAdapter({
    pool: {
      connectionString: process.env.DATABASE_URI || '',
    },
  }),
  sharp,
})
EOFCONFIG

# Create Collections

# Users collection
cat > src/collections/Users.ts << 'EOFUSERS'
import type { CollectionConfig } from 'payload'

export const Users: CollectionConfig = {
  slug: 'users',
  auth: true,
  admin: {
    useAsTitle: 'email',
  },
  fields: [
    {
      name: 'name',
      type: 'text',
    },
    {
      name: 'roles',
      type: 'select',
      hasMany: true,
      options: [
        { label: 'Admin', value: 'admin' },
        { label: 'Editor', value: 'editor' },
        { label: 'Viewer', value: 'viewer' },
      ],
      defaultValue: ['viewer'],
      required: true,
    },
    {
      name: 'tenant',
      type: 'relationship',
      relationTo: 'tenants',
      required: false,
      admin: {
        description: 'Assign user to a specific tenant. Leave empty for super admins.',
      },
    },
  ],
}
EOFUSERS

# Tenants collection
cat > src/collections/Tenants.ts << 'EOFTENANTS'
import type { CollectionConfig } from 'payload'

export const Tenants: CollectionConfig = {
  slug: 'tenants',
  admin: {
    useAsTitle: 'name',
    defaultColumns: ['name', 'slug', 'domain'],
  },
  access: {
    read: () => true,
  },
  fields: [
    {
      name: 'name',
      type: 'text',
      required: true,
      label: 'Tenant Name',
    },
    {
      name: 'slug',
      type: 'text',
      required: true,
      unique: true,
      label: 'Slug',
      admin: {
        description: 'Unique identifier for this tenant',
      },
    },
    {
      name: 'domain',
      type: 'text',
      required: true,
      label: 'Domain',
      admin: {
        description: 'Primary domain for this tenant (e.g., subdomain.jumpstartscaling.com)',
      },
    },
    {
      name: 'additionalDomains',
      type: 'array',
      label: 'Additional Domains',
      fields: [
        {
          name: 'domain',
          type: 'text',
          required: true,
        },
      ],
    },
    {
      name: 'logo',
      type: 'upload',
      relationTo: 'media',
      label: 'Logo',
    },
    {
      name: 'primaryColor',
      type: 'text',
      label: 'Primary Color',
      admin: {
        description: 'Hex color code (e.g., #FF5733)',
      },
    },
    {
      name: 'active',
      type: 'checkbox',
      label: 'Active',
      defaultValue: true,
    },
  ],
}
EOFTENANTS

# Pages collection
cat > src/collections/Pages.ts << 'EOFPAGES'
import type { CollectionConfig } from 'payload'

export const Pages: CollectionConfig = {
  slug: 'pages',
  admin: {
    useAsTitle: 'title',
    defaultColumns: ['title', 'slug', 'tenant', 'status'],
  },
  versions: {
    drafts: true,
  },
  fields: [
    {
      name: 'title',
      type: 'text',
      required: true,
    },
    {
      name: 'slug',
      type: 'text',
      required: true,
      admin: {
        description: 'URL-friendly version of the title',
      },
    },
    {
      name: 'tenant',
      type: 'relationship',
      relationTo: 'tenants',
      required: true,
      admin: {
        description: 'Which tenant does this page belong to?',
      },
    },
    {
      name: 'content',
      type: 'richText',
      required: false,
    },
    {
      name: 'status',
      type: 'select',
      options: [
        { label: 'Draft', value: 'draft' },
        { label: 'Published', value: 'published' },
      ],
      defaultValue: 'draft',
      required: true,
    },
    {
      name: 'publishedAt',
      type: 'date',
      admin: {
        date: {
          pickerAppearance: 'dayAndTime',
        },
      },
    },
  ],
  hooks: {
    beforeChange: [
      ({ data, operation }) => {
        if (operation === 'create' || operation === 'update') {
          if (data.status === 'published' && !data.publishedAt) {
            data.publishedAt = new Date().toISOString()
          }
        }
        return data
      },
    ],
  },
}
EOFPAGES

# Media collection
cat > src/collections/Media.ts << 'EOFMEDIA'
import type { CollectionConfig } from 'payload'

export const Media: CollectionConfig = {
  slug: 'media',
  upload: {
    staticDir: 'media',
    imageSizes: [
      {
        name: 'thumbnail',
        width: 400,
        height: 300,
        position: 'centre',
      },
      {
        name: 'card',
        width: 768,
        height: 1024,
        position: 'centre',
      },
      {
        name: 'tablet',
        width: 1024,
        height: undefined,
        position: 'centre',
      },
    ],
    adminThumbnail: 'thumbnail',
    mimeTypes: ['image/*'],
  },
  fields: [
    {
      name: 'alt',
      type: 'text',
      required: true,
    },
    {
      name: 'tenant',
      type: 'relationship',
      relationTo: 'tenants',
      required: false,
      admin: {
        description: 'Optional: Assign to specific tenant',
      },
    },
  ],
}
EOFMEDIA

# Create Next.js app structure
cat > src/app/layout.tsx << 'EOFLAYOUT'
import React from 'react'
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'JumpStart Scaling CMS',
  description: 'Multi-tenant content management system',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOFLAYOUT

cat > src/app/globals.css << 'EOFCSS'
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
EOFCSS

cat > src/app/page.tsx << 'EOFPAGE'
import React from 'react'
import Link from 'next/link'

export default function Home() {
  return (
    <div style={{ padding: '2rem', maxWidth: '800px', margin: '0 auto' }}>
      <h1>🚀 JumpStart Scaling CMS</h1>
      <p style={{ margin: '1rem 0' }}>
        Multi-tenant content management system powered by Payload CMS.
      </p>
      <div style={{ marginTop: '2rem' }}>
        <Link 
          href="/admin" 
          style={{ 
            padding: '0.5rem 1rem', 
            background: '#0070f3', 
            color: 'white', 
            textDecoration: 'none',
            borderRadius: '4px',
            display: 'inline-block'
          }}
        >
          Go to Admin Dashboard →
        </Link>
      </div>
    </div>
  )
}
EOFPAGE

cat > src/app/(payload)/admin/[[...segments]]/page.tsx << 'EOFADMIN'
/* THIS FILE WAS GENERATED AUTOMATICALLY BY PAYLOAD. */
import type { Metadata } from 'next'

import config from '@payload-config'
import { RootPage, generatePageMetadata } from '@payloadcms/next/views'
import { importMap } from '../importMap'

type Args = {
  params: Promise<{
    segments: string[]
  }>
  searchParams: Promise<{
    [key: string]: string | string[]
  }>
}

export const generateMetadata = ({ params, searchParams }: Args): Promise<Metadata> =>
  generatePageMetadata({ config, params, searchParams })

const Page = ({ params, searchParams }: Args) =>
  RootPage({ config, params, searchParams, importMap })

export default Page
EOFADMIN

cat > src/app/(payload)/admin/importMap.js << 'EOFIMPORT'
export const importMap = {}
EOFIMPORT

# Create Payload config reference for Next.js
cat > src/payload-config.ts << 'EOFREF'
import config from './payload.config'
export default config
EOFREF

# Create favicon placeholder
echo "" > public/favicon.ico

echo "✅ Project structure created"
echo "📦 Installing dependencies..."

npm install

echo "✅ Dependencies installed"
echo "📝 Initializing git..."

git init
git add .
git commit -m "Initial Payload multi-tenant CMS setup"

echo "✅ Setup complete!"
EOFSETUP

echo ""
echo "✅ PAYLOAD APP CREATED SUCCESSFULLY!"
echo ""
echo "📁 Location: /home/opc/payload-multitenant"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Create a GitHub repository at https://github.com/new"
echo ""
echo "2. Push code to GitHub:"
echo "   ssh -i ~/.ssh/id_rsa $SERVER"
echo "   cd /home/opc/payload-multitenant"
echo "   git remote add origin [YOUR_REPO_URL]"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Set up PostgreSQL database in Coolify"
echo "4. Deploy the app in Coolify pointing to your GitHub repo"
echo ""
