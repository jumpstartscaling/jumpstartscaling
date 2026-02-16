#!/bin/bash
# ==============================================================================
# 🚀 SPARK ECOSYSTEM: COMPLETE VISUAL STACK INSTALLER
# Installs MDX, 3D, Animation, and Data Viz libraries for both sites
# ==============================================================================

set -e  # Exit on error

# 1. Configuration
REMOTE_USER="opc"
REMOTE_IP="150.136.117.198"
REMOTE_BASE="/home/opc/sites"

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================================"
echo "🎨 VISUAL STACK UPGRADE FOR SPARK ECOSYSTEM"
echo "================================================================"

# List of all visual libraries
CORE_DEPS="framer-motion clsx tailwind-merge"
THREE_D="three @types/three @react-three/fiber @react-three/drei @react-three/cannon @splinetool/react-spline"
DATA_VIZ="recharts"
UX_LIBS="@studio-freight/lenis @rive-app/react-canvas react-rough-notation canvas-confetti @formkit/auto-animate"
ICONS="lucide-react"
UTILS="maath"

ALL_DEPS="$CORE_DEPS $THREE_D $DATA_VIZ $UX_LIBS $ICONS $UTILS"

# Function to setup a single site
setup_site() {
    local SITE_NAME=$1
    local LOCAL_PATH="sites/$SITE_NAME"
    local REMOTE_PATH="$REMOTE_BASE/$SITE_NAME"
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📦 Setting up: $SITE_NAME${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # LOCAL INSTALLATION
    echo -e "${GREEN}[LOCAL]${NC} Installing Astro integrations..."
    cd "$LOCAL_PATH"
    
    # Add Astro integrations (MDX, Tailwind)
    npx astro add mdx tailwind -y || true
    
    echo -e "${GREEN}[LOCAL]${NC} Installing visual libraries..."
    npm install $ALL_DEPS
    
    cd ../..  # Back to root
    
    # REMOTE INSTALLATION
    echo -e "${GREEN}[REMOTE]${NC} Installing on Oracle server..."
    ssh $REMOTE_USER@$REMOTE_IP "cd $REMOTE_PATH && npx astro add mdx tailwind -y && npm install $ALL_DEPS" || {
        echo -e "${YELLOW}⚠️  Remote installation failed. You may need to run it manually.${NC}"
    }
    
    echo -e "${GREEN}✅ $SITE_NAME setup complete!${NC}"
}

# Setup both sites
setup_site "jumpstartscaling"
setup_site "chrisamaya"

# Sync files to server
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🔄 Syncing source files to server...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
./sync_sites.sh

# Restart PM2 services
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}🔥 Restarting PM2 services...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
ssh $REMOTE_USER@$REMOTE_IP "pm2 restart jumpstart-v2 chrisamaya-v2"

echo ""
echo "================================================================"
echo -e "${GREEN}🎉 VISUAL STACK INSTALLATION COMPLETE!${NC}"
echo "================================================================"
echo ""
echo "Installed capabilities:"
echo "  ✓ MDX (Markdown + JSX)"
echo "  ✓ Tailwind CSS"
echo "  ✓ 3D Engine (React Three Fiber + Drei)"
echo "  ✓ Physics (Cannon)"
echo "  ✓ Animations (Framer Motion)"
echo "  ✓ Data Visualization (Recharts)"
echo "  ✓ Smooth Scrolling (Lenis)"
echo "  ✓ Interactive Mascots (Rive)"
echo "  ✓ Text Effects (Rough Notation)"
echo "  ✓ Confetti & Micro-interactions"
echo "  ✓ Icons (Lucide React)"
echo ""
echo "⚠️  IMPORTANT: Check astro.config.mjs files to ensure allowedHosts is preserved!"
echo ""
