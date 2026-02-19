# 🚀 QUICKEST PATH TO DEPLOYMENT

Since GitHub authentication is needed, here's the **fastest 2-step solution**:

## Option A: Push from Your Local Machine (Recommended - 2 minutes)

```bash
# 1. Download the code from server (without node_modules for speed)
cd /tmp
rm -rf payload-cms-deploy
mkdir payload-cms-deploy
cd payload-cms-deploy

# Download only source files (not node_modules)
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 "cd /home/opc/payload-multitenant && tar --exclude='node_modules' --exclude='.git' -czf /tmp/payload-source.tar.gz ." 

scp -i ~/.ssh/id_rsa opc@193.122.168.215:/tmp/payload-source.tar.gz .
tar -xzf payload-source.tar.gz

# 2. Initialize git and push to GitHub (you're already authenticated)
git init
git add .
git commit -m "Initial Payload CMS multi-tenant setup"
git branch -M main  
git remote add origin https://github.com/jumpstartscaling/jumpstartscaling.git
git push -u origin main --force

# Done! Code is on GitHub
```

## Option B: Use GitHub Token on Server (1 minute)

If you have a GitHub Personal Access Token (PAT):

```bash
# Set your GitHub token
export GITHUB_TOKEN="your_github_personal_access_token_here"

# Push from server
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 << EOF
cd /home/opc/payload-multitenant
git remote set-url origin https://${GITHUB_TOKEN}@github.com/jumpstartscaling/jumpstartscaling.git
git push -u origin main --force
echo "✅ Pushed to GitHub!"
EOF
```

**To create a GitHub PAT:**
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control)
4. Copy the token

---

## After Code is on GitHub

### Deploy in Coolify (5 minutes):

1. **Open Coolify**: http://193.122.168.215:8000

2. **Create PostgreSQL Database**:
   - Click "+ New Resource" → "PostgreSQL"
   - Name: `jumpstart-cms-db`
   - Version: 16
   - Database: `payload`
   - User: `payload_user`
   - **Save the password and connection string!**

3. **Create Application**:
   - "+ New Resource" → "Application"
   - Repository: `https://github.com/jumpstartscaling/jumpstartscaling`
   - Branch: `main`
   - Build Pack: Dockerfile (auto-detect)

4. **Environment Variables**:
   ```
   DATABASE_URI=<postgres_connection_string_from_step_2>
   PAYLOAD_SECRET=<run: openssl rand -base64 32>
   PAYLOAD_CONFIG_PATH=src/payload.config.ts
   NEXT_PUBLIC_SERVER_URL=https://cms.jumpstartscaling.com
   PORT=3000
   NODE_ENV=production
   ```

5. **Set Domain**:
   - Domain: `cms.jumpstartscaling.com`
   - Enable SSL

6. **Deploy**:
   - Click "Deploy"
   - Wait 5-10 minutes for build

7. **Add DNS** (while building):
   ```
   Type: A
   Name: cms
   Content: 193.122.168.215
   Proxy: ON
   ```

8. **Access**:
   - Visit: https://cms.jumpstart scaling.com
 - Create admin user
   - Create first tenant: "JumpStart Scaling Hub"
   - Done! 🎉

---

## 🎯 Choose Your Path

- **Fastest**: Option A (no token needed, uses your existing GitHub auth)
- **Simplest**: Option B (if you have or can quickly create a GitHub PAT)

Both take ~2 minutes + 5-10 min Coolify build time = **~15 minutes total to live CMS**

---

**Current Status**: 
✅ Code ready on server at `/home/opc/payload-multitenant`
✅ Dockerfile created
✅ All dependencies installed  
⏳ **Needs**: Push to GitHub → Deploy in Coolify

**Choose Option A or B above and let's deploy!** 🚀
