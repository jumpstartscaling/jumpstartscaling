#!/bin/bash
# Push Payload CMS to GitHub - Interactive Script

set -e

SERVER="opc@193.122.168.215"
REPO_URL="https://github.com/jumpstartscaling/jumpstartscaling.git"

echo "🚀 Push Payload CMS to GitHub"
echo "=============================="
echo ""
echo "This script will help you push the Payload CMS code to:"
echo "$REPO_URL"
echo ""

echo "⚠️  You'll need either:"
echo "1. GitHub Personal Access Token (PAT)"
echo "2. GitHub username and password"
echo "3. OR we can download the code and you can push from your local machine"
echo ""

read -p "Choose method (1=PAT, 2=Username/Password, 3=Download): " method

if [ "$method" = "1" ]; then
    echo ""
    read -p "Enter your GitHub Personal Access Token: " -s token
    echo ""
    
    ssh -i ~/.ssh/id_rsa $SERVER << EOFPUSH
cd /home/opc/payload-multitenant
git remote set-url origin https://${token}@github.com/jumpstartscaling/jumpstartscaling.git
git push -u origin main --force
EOFPUSH
    
    echo "✅ Code pushed to GitHub!"
    
elif [ "$method" = "2" ]; then
    echo ""
    read -p "Enter GitHub username: " username
    read -p "Enter GitHub password/token: " -s password
    echo ""
    
    ssh -i ~/.ssh/id_rsa $SERVER << EOFPUSH
cd /home/opc/payload-multitenant
git remote set-url origin https://${username}:${password}@github.com/jumpstartscaling/jumpstartscaling.git
git push -u origin main --force
EOFPUSH
    
    echo "✅ Code pushed to GitHub!"
    
elif [ "$method" = "3" ]; then
    echo ""
    echo "📥 Downloading code from server..."
    
    # Create temp directory
    TEMP_DIR="/tmp/payload-cms-github-push"
    rm -rf $TEMP_DIR
    mkdir -p $TEMP_DIR
    
    # Download from server
    scp -i ~/.ssh/id_rsa -r $SERVER:/home/opc/payload-multitenant/* $TEMP_DIR/
    
    cd $TEMP_DIR
    
    echo "✅ Code downloaded to: $TEMP_DIR"
    echo ""
    echo "Now pushing to GitHub from your local machine..."
    
    git remote set-url origin $REPO_URL 2>/dev/null || git remote add origin $REPO_URL
    git push -u origin main --force
    
    echo "✅ Code pushed to GitHub!"
    echo "🗑️  Cleaning up temp directory..."
    rm -rf $TEMP_DIR
    
else
    echo "❌ Invalid option"
    exit 1
fi

echo ""
echo "✅ SUCCESS! Code is now on GitHub at:"
echo "$REPO_URL"
echo ""
echo "🚀 Next: Deploy in Coolify"
echo "1. Go to http://193.122.168.215:8000"
echo "2. Create new application from GitHub repo"
echo "3. Use: https://github.com/jumpstartscaling/jumpstartscaling"
echo "4. Branch: main"
echo ""
