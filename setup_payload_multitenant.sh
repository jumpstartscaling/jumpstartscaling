#!/bin/bash
# 🚀 Payload Multi-Tenant Setup for jumpstartscaling.com
# This script sets up a fresh Payload CMS multi-tenant application on Coolify

set -e

SERVER="opc@193.122.168.215"
PROJECT_NAME="jumpstartscaling-cms"
APP_DIR="/home/opc/payload-multitenant"

echo "🧹 Step 1: Cleaning up old Coolify applications..."

# Delete old applications from Coolify database
ssh -i ~/.ssh/id_rsa $SERVER << 'EOF'
echo "Stopping and removing old application containers..."
docker stop $(docker ps -aq --filter "name=jumpstartscaling" --filter "name=dockerfile-") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=jumpstartscaling" --filter "name=dockerfile-") 2>/dev/null || true

echo "Cleaning up database records..."
docker exec coolify-db psql -U coolify -d coolify -c "DELETE FROM applications WHERE id IN (1,2,3,4,5);"

echo "✅ Old applications cleaned up"
EOF

echo ""
echo "📦 Step 2: Creating fresh Payload multi-tenant app on server..."

ssh -i ~/.ssh/id_rsa $SERVER << 'EOFSERVER'
# Clean up old payload directories if they exist
rm -rf /home/opc/payload-multitenant
rm -rf /home/opc/payload*

# Create project directory
mkdir -p /home/opc/payload-multitenant
cd /home/opc/payload-multitenant

# Initialize Payload project with multi-tenant template
echo "Creating Payload app with Next.js..."
npx -y create-payload-app@latest . \
  --template blank \
  --db postgres \
  --no-deps

echo "✅ Payload app created"
EOFSERVER

echo ""
echo "🔧 Step 3: Configuring multi-tenant plugin..."

# Create the multi-tenant configuration file
ssh -i ~/.ssh/id_rsa $SERVER << 'EOFCONFIG'
cd /home/opc/payload-multitenant

# Install multi-tenant plugin
npm install @payloadcms/plugin-multi-tenant

# Create payload config with multi-tenant
cat > src/payload.config.ts << 'EOFPAYLOAD'
import { buildConfig } from 'payload'
import { mongooseAdapter } from '@payloadcms/db-mongodb'
import { lexicalEditor } from '@payloadcms/richtext-lexical'
import { multiTenant } from '@payloadcms/plugin-multi-tenant'
import path from 'path'
import { fileURLToPath } from 'url'

const filename = fileURLToPath(import.meta.url)
const dirname = path.dirname(filename)

export default buildConfig({
  admin: {
    user: 'users',
    meta: {
      titleSuffix: '- JumpStart Scaling CMS',
      favicon: '/favicon.ico',
      ogImage: '/og-image.png',
    },
  },
  collections: [
    {
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
      ],
    },
    {
      slug: 'tenants',
      admin: {
        useAsTitle: 'name',
      },
      fields: [
        {
          name: 'name',
          type: 'text',
          required: true,
        },
        {
          name: 'slug',
          type: 'text',
          required: true,
          unique: true,
        },
        {
          name: 'domains',
          type: 'array',
          required: true,
          fields: [
            {
              name: 'domain',
              type: 'text',
              required: true,
            },
          ],
        },
      ],
    },
    {
      slug: 'pages',
      admin: {
        useAsTitle: 'title',
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
        },
        {
          name: 'content',
          type: 'richText',
          editor: lexicalEditor({}),
        },
        {
          name: 'publishedAt',
          type: 'date',
        },
      ],
    },
  ],
  editor: lexicalEditor({}),
  secret: process.env.PAYLOAD_SECRET || 'your-secret-key-here',
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  db: mongooseAdapter({
    url: process.env.DATABASE_URI || '',
  }),
  plugins: [
    multiTenant({
      tenantCollection: 'tenants',
      isolationStrategy: 'domain',
    }),
  ],
})
EOFPAYLOAD

echo "✅ Payload config created with multi-tenant support"
EOFCONFIG

echo ""
echo "📝 Step 4: Creating environment variables template..."

ssh -i ~/.ssh/id_rsa $SERVER << 'EOFENV'
cd /home/opc/payload-multitenant

cat > .env.example << 'EOFENVFILE'
# Database
DATABASE_URI=mongodb://localhost:27017/payload-multitenant

# Payload
PAYLOAD_SECRET=your-super-secret-key-change-this
PAYLOAD_CONFIG_PATH=src/payload.config.ts

# Server
NEXT_PUBLIC_SERVER_URL=https://cms.jumpstartscaling.com
PORT=3000

# Tenant Hub
HUB_DOMAIN=jumpstartscaling.com
EOFENVFILE

echo "✅ Environment template created"
EOFENV

echo ""
echo "🎯 Step 5: Creating GitHub repository initialization..."

ssh -i ~/.ssh/id_rsa $SERVER << 'EOFGIT'
cd /home/opc/payload-multitenant

# Initialize git
git init
git add .
git commit -m "Initial Payload multi-tenant setup for jumpstartscaling.com"

echo "✅ Git repository initialized"
EOFGIT

echo ""
echo "✅ SETUP COMPLETE!"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Create a GitHub repository for this project:"
echo "   - Go to https://github.com/new"
echo "   - Name it 'payload-multitenant' or similar"
echo "   - Copy the repository URL"
echo ""
echo "2. Push the code to GitHub:"
echo "   ssh -i ~/.ssh/id_rsa $SERVER"
echo "   cd /home/opc/payload-multitenant"
echo "   git remote add origin [YOUR_GITHUB_REPO_URL]"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Set up in Coolify (http://193.122.168.215:8000):"
echo "   - Create a new Project named 'JumpStart Scaling CMS'"
echo "   - Add a MongoDB database resource"
echo "   - Add a new Application from your GitHub repository"
echo "   - Configure environment variables in Coolify:"
echo "     * DATABASE_URI: [MongoDB connection string from Coolify]"
echo "     * PAYLOAD_SECRET: [Generate a random 32+ character string]"
echo "     * NEXT_PUBLIC_SERVER_URL: https://cms.jumpstartscaling.com"
echo "     * HUB_DOMAIN: jumpstartscaling.com"
echo "   - Set domain to: cms.jumpstartscaling.com"
echo "   - Deploy!"
echo ""
echo "4. DNS Configuration:"
echo "   Add A record: cms.jumpstartscaling.com → 193.122.168.215"
echo ""
echo "5. Access your CMS at:"
echo "   https://cms.jumpstartscaling.com/admin"
echo ""
