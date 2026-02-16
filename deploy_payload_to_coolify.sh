#!/bin/bash
# Deploy Payload CMS to Coolify directly from server directory

set -e

echo "🚀 Deploying Payload CMS to Coolify..."
echo ""

# Server connection
SERVER="opc@193.122.168.215"
COOLIFY_URL="http://193.122.168.215:8000"
PROJECT_PATH="/home/opc/payload-multitenant"

echo "📦 Step 1: Verifying project on server..."
ssh -i ~/.ssh/id_rsa $SERVER "cd $PROJECT_PATH && ls -la && echo '✅ Project exists'"

echo ""
echo "🗄️  Step 2: Createing PostgreSQL Database in Coolify..."
echo ""
echo "MANUAL ACTION REQUIRED:"
echo "1. Open Coolify: $COOLIFY_URL"
echo "2. Log in if needed"
echo "3. Click '+ New Resource' → 'PostgreSQL'"
echo "4. Configure:"
echo "   - Name: jumpstart-cms-db"
echo "   - Version: 16"
echo "   - Database Name: payload"
echo "   - Username: payload_user"
echo "   - Password: (auto-generated - SAVE THIS!)"
echo "5. Click 'Create'"
echo "6. Wait for green status"
echo "7. Copy the Internal Connection String"
echo ""
read -p "Press ENTER when database is created and you have the connection string..."

echo ""
echo "📝 Step 3: Create Coolify Application..."
echo ""
echo "MANUAL ACTION REQUIRED:"
echo "1. In Coolify, create new Project:"
echo "   - Name: JumpStart CMS"
echo "2. Click '+ New Resource' → 'Application'"
echo "3. Select 'Dockerfile' (since we'll use local directory)"
echo "4. OR select 'Public Repository' and use:"
echo "   https://gitthis.jumpstartscaling.com/gatekeeper/payload-cms.git"
echo ""
read -p "Which method? (1=Dockerfile/Local, 2=Git Repository) [1/2]: " method

if [ "$method" = "1" ]; then
    echo ""
    echo "📝 For Dockerfile deployment:"
    echo "1. Create a simple Dockerfile in the project"
    echo "2. Use Nixpacks build pack (auto-detection)"
    echo "3. Set build directory to source"
    echo ""
    
    # Create Dockerfile on server
    ssh -i ~/.ssh/id_rsa $SERVER << 'EOFDOCKER'
cd /home/opc/payload-multitenant
cat > Dockerfile << 'EOF'
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy project files
COPY . .

# Build the application
RUN npm run build

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "run", "start"]
EOF

echo "✅ Dockerfile created"
EOFDOCKER

    echo ""
    echo "✅ Dockerfile created on server"
    echo ""
fi

echo ""
echo "⚙️  Step 4: Configure Environment Variables in Coolify..."
echo ""
echo "Add these environment variables in Coolify:"
echo ""
echo "DATABASE_URI=<YOUR_POSTGRES_CONNECTION_STRING>"
echo "PAYLOAD_SECRET=$(openssl rand -base64 32)"
echo "PAYLOAD_CONFIG_PATH=src/payload.config.ts"
echo "NEXT_PUBLIC_SERVER_URL=https://cms.jumpstartscaling.com"
echo "PORT=3000"
echo "NODE_ENV=production"
echo ""
read -p "Press ENTER when environment variables are configured..."

echo ""
echo "🌐 Step 5: Set Domain in Coolify..."
echo ""
echo "1. Go to 'Domains' tab"
echo "2. Add domain: cms.jumpstartscaling.com"
echo "3. Enable SSL/TLS"
echo "4. Save"
echo ""
read -p "Press ENTER when domain is configured..."

echo ""
echo "🚀 Step 6: Deploy!"
echo ""
echo "Click 'Deploy' button in Coolify and monitor the build logs"
echo ""
read -p "Press ENTER when deployment is complete..."

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo ""
echo "📊 Verification Steps:"
echo "1. Visit: https://cms.jumpstartscaling.com"
echo "2. Should see: 'JumpStart Scaling CMS' homepage"
echo "3. Click 'Go to Admin Dashboard'"
echo "4. Create first admin user"
echo "5. Create first tenant (JumpStart Scaling Hub)"
echo ""
echo "🎉 Your multi-tenant Payload CMS is now live!"
echo ""
echo "📚 Documentation:"
echo "- Full Guide: PAYLOAD_CMS_DEPLOYMENT_GUIDE.md"
echo "- Quick Ref: PAYLOAD_QUICK_REFERENCE.md"
echo ""
