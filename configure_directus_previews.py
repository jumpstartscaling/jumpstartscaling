"""
Configure Directus Preview URLs for Multi-Site Content
This sets up the visual editor to work with multi-tenant sites
"""

import requests
import json

DIRECTUS_URL = "https://office.jumpstartscaling.com"
ADMIN_TOKEN = "NbGrYlTL0t_AjaFhAH6D0q5biUHAMOkz"

headers = {
    "Authorization": f"Bearer {ADMIN_TOKEN}",
    "Content-Type": "application/json"
}

def configure_collection_preview(collection_name, preview_url_template):
    """Configure preview URL for a collection"""
    
    # Get collection metadata
    response = requests.get(
        f"{DIRECTUS_URL}/collections/{collection_name}",
        headers=headers
    )
    
    if response.status_code == 200:
        print(f"✅ Found collection: {collection_name}")
    else:
        print(f"❌ Collection not found: {collection_name}")
        return
    
    # Update collection meta with preview URL
    update_data = {
        "meta": {
            "preview_url": preview_url_template
        }
    }
    
    response = requests.patch(
        f"{DIRECTUS_URL}/collections/{collection_name}",
        headers=headers,
        json=update_data
    )
    
    if response.status_code == 200:
        print(f"✅ Preview URL configured for {collection_name}")
        print(f"   Template: {preview_url_template}")
    else:
        print(f"❌ Failed to configure: {response.text}")

# Configure preview URLs
print("🔱 Configuring Directus Preview URLs...\n")

# For Pages
configure_collection_preview(
    "pages",
    "https://spark.jumpstartscaling.com/{{site.domain}}/{{slug}}"
)

print()

# For Posts
configure_collection_preview(
    "posts",
    "https://spark.jumpstartscaling.com/{{site.domain}}/{{slug}}"
)

print("\n✅ Preview URLs configured!")
print("\nHow to test:")
print("1. Go to https://office.jumpstartscaling.com")
print("2. Open Content → Pages")
print("3. Edit any page")
print("4. Click the eye icon (Preview)")
print("5. Should open preview in iframe!")
