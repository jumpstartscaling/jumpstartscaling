#!/bin/bash
# Minimal SEO Patch - Only adds meta tags to working version
# This avoids the Astro parser bug by not touching the frontmatter

SERVER="opc@150.136.117.198"
SITE_PATH="/home/opc/sites/jumpstartscaling/src/pages"

echo "🎯 Injecting SEO Meta Tags (Minimal Patch)"
echo "=========================================="

# Create the meta tags to inject (after line 12: meta description)
ssh $SERVER "cd $SITE_PATH && sed -i '12 a\\    <meta name=\"generator\" content={Astro.generator} />\\n    \\n    <!-- Open Graph -->\\n    <meta property=\"og:type\" content=\"website\" />\\n    <meta property=\"og:url\" content=\"https://jumpstartscaling.com\" />\\n    <meta property=\"og:title\" content={title} />\\n    <meta property=\"og:description\" content={description} />\\n    <meta property=\"og:image\" content=\"https://jumpstartscaling.com/og-social.jpg\" />\\n    \\n    <!-- Twitter -->\\n    <meta name=\"twitter:card\" content=\"summary_large_image\" />\\n    <meta name=\"twitter:title\" content={title} />\\n    <meta name=\"twitter:description\" content={description} />\\n    <meta name=\"twitter:image\" content=\"https://jumpstartscaling.com/og-social.jpg\" />\\n    \\n    <!-- Canonical -->\\n    <link rel=\"canonical\" href=\"https://jumpstartscaling.com\" />' index.astro"

echo "✅ Meta tags injected!"
echo ""
echo "🔨 Building site..."
ssh $SERVER "cd /home/opc/sites/jumpstartscaling && npm run build"
echo ""
echo "✅ Done! Visit https://jumpstartscaling.com"
