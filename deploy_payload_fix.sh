#!/bin/bash

# Payload CMS - Enable Auto-Push & SSL Configuration
# This script updates the Payload config and triggers redeployment

set -e

echo "🚀 Payload CMS Deployment Script"
echo "=================================="
echo ""

# Configuration
SERVER_IP="193.122.168.215"
SSH_KEY="~/.ssh/id_rsa"
PAYLOAD_DIR="/home/opc/payload-multitenant"
DOMAIN="cms.jumpstartscaling.com"

echo "📝 Step 1: Updating payload.config.ts to enable auto-push..."
ssh -i $SSH_KEY opc@$SERVER_IP << 'ENDSSH'
cd /home/opc/payload-multitenant

# Backup original config
cp src/payload.config.ts src/payload.config.ts.backup

# Update config with push: true
cat > src/payload.config.ts << 'EOF'
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
      titleSuffix: '- JumpStart Scaling',
    },
  },
  collections: [Users, Tenants, Pages, Media],
  editor: lexicalEditor({}),
  secret: process.env.PAYLOAD_SECRET || '',
  typescript: {
    outputFile: path.resolve(dirname, 'payload-types.ts'),
  },
  db: postgresAdapter({
    pool: {
      connectionString: process.env.DATABASE_URI || '',
    },
    push: true, // Auto-create and update database tables
  }),
  sharp,
})
EOF

echo "✅ Config updated with push: true"
ENDSSH

echo ""
echo "🔨 Step 2: Rebuilding application..."
ssh -i $SSH_KEY opc@$SERVER_IP << 'ENDSSH'
cd /home/opc/payload-multitenant

# Install dependencies (if needed)
npm install

# Build the application
npm run build

echo "✅ Build completed"
ENDSSH

echo ""
echo "🔒 Step 3: Configuring SSL certificate..."
echo "Note: SSL is already configured via Cloudflare proxy"
echo "Cloudflare handles SSL termination automatically"

echo ""
echo "🔄 Step 4: Finding and restarting Payload CMS container..."
ssh -i $SSH_KEY opc@$SERVER_IP << 'ENDSSH'
# Find the Payload CMS container
CONTAINER_ID=$(docker ps --filter "name=ksgwgg0kg08o000s80wcgkks" --format "{{.ID}}")

if [ -z "$CONTAINER_ID" ]; then
  echo "❌ Error: Could not find Payload CMS container"
  exit 1
fi

echo "Found container: $CONTAINER_ID"
echo "Restarting container..."

docker restart $CONTAINER_ID

echo "✅ Container restarted"
echo ""
echo "Waiting for application to start..."
sleep 10

# Check if container is running
if docker ps | grep -q $CONTAINER_ID; then
  echo "✅ Container is running"
else
  echo "❌ Container failed to start"
  echo "Checking logs:"
  docker logs $CONTAINER_ID --tail 50
  exit 1
fi
ENDSSH

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "🎉 Your Payload CMS should now be accessible at:"
echo "   https://cms.jumpstartscaling.com"
echo ""
echo "📋 Next Steps:"
echo "   1. Visit https://cms.jumpstartscaling.com"
echo "   2. Complete the Payload CMS setup wizard"
echo "   3. Create your first admin user"
echo "   4. Create your first tenant"
echo ""
echo "🔍 To check logs:"
echo "   ssh -i ~/.ssh/id_rsa opc@$SERVER_IP"
echo "   docker logs \$(docker ps --filter 'name=ksgwgg0kg08o000s80wcgkks' --format '{{.ID}}') -f"
echo ""
