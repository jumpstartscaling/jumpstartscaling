#!/bin/bash
# Deploy all 3 repos to GitHub. Run from god-mode directory.
# Prerequisites: gh auth login (complete in browser when prompted)

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPARK_DIR="$(dirname "$SCRIPT_DIR")"
ORG="${GITHUB_ORG:-caw-jump}"

echo "=== GitHub Repo Deployment ==="
echo "Target: github.com/$ORG"
echo ""

# Check gh auth
if ! gh auth status &>/dev/null; then
    echo "❌ GitHub CLI not authenticated. Run: gh auth login"
    echo "   Complete the browser flow, then re-run this script."
    exit 1
fi

# 1. jumpstartscaling-site
echo ">>> jumpstartscaling-site"
cd "$SPARK_DIR/jumpstartscaling-site"
gh repo create "$ORG/jumpstartscaling-site" --private --source=. --remote=origin --push 2>/dev/null || {
    echo "   Repo may exist, pushing..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$ORG/jumpstartscaling-site.git"
    git push -u origin main
}
echo "✅ jumpstartscaling-site done"

# 2. chrisamaya-site
echo ">>> chrisamaya-site"
cd "$SPARK_DIR/chrisamaya-site"
gh repo create "$ORG/chrisamaya-site" --private --source=. --remote=origin --push 2>/dev/null || {
    echo "   Repo may exist, pushing..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$ORG/chrisamaya-site.git"
    git push -u origin main
}
echo "✅ chrisamaya-site done"

# 3. god-mode-api
echo ">>> god-mode-api"
cd "$SPARK_DIR/god-mode-api"

# Try to pull Django source from Oracle (optional - may fail if not on same network)
if [ -f ./pull-from-oracle.sh ]; then
    echo "   Attempting to pull Django source from Oracle..."
    if ./pull-from-oracle.sh 2>/dev/null; then
        echo "   Pulled from Oracle ✅"
    else
        echo "   Oracle pull skipped (run ./pull-from-oracle.sh manually when you have SSH access)"
    fi
fi

# Init git if needed
if [ ! -d .git ]; then
    git init
    git add .
    git commit -m "Initial commit - God Mode Django API"
fi

gh repo create "$ORG/god-mode-api" --private --source=. --remote=origin --push 2>/dev/null || {
    echo "   Repo may exist, pushing..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "https://github.com/$ORG/god-mode-api.git"
    git push -u origin main
}
echo "✅ god-mode-api done"

echo ""
echo "🎉 All repos pushed to GitHub!"
echo ""
echo "Next: Add them as sources in Coolify (http://86.48.23.38:8000)"
echo "  - $ORG/jumpstartscaling-site"
echo "  - $ORG/chrisamaya-site"
echo "  - $ORG/god-mode-api"
