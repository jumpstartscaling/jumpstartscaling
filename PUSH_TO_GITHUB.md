# 🚀 PUSH TO GITHUB VIA SSH - COMPLETE GUIDE

## Current Status

✅ SSH key generated on server  
✅ Git configured to use SSH  
✅ Local commit ready: `c617a7a Enable auto-push for database tables`  
❌ SSH key not added to GitHub yet

---

## 🔑 Step 1: Add SSH Key to GitHub (1 minute)

### Copy this SSH public key:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcWb1z5SyRmY8UHHC4pqUXyuDOE//mK+OpqAXx0Ei5L deploy@jumpstartscaling.com
```

### Add to GitHub:

1. **Click this link:** https://github.com/settings/ssh/new

2. **Fill in the form:**
   - **Title:** `Coolify Server - Payload CMS Deploy`
   - **Key type:** Authentication Key
   - **Key:** Paste the SSH key above

3. **Click:** "Add SSH key"

4. **Confirm** with your password if prompted

---

## 📤 Step 2: Push the Changes

Once you've added the SSH key to GitHub, tell me and I'll run:

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 \
  'cd /home/opc/payload-multitenant && \
   GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519" \
   git push origin main'
```

---

## 🔄 Step 3: Redeploy in Coolify

After pushing:

1. **Open:** http://spark.jumpstartscaling.com:8000
2. **Find:** Payload CMS application
3. **Click:** "Redeploy"
4. **Wait:** 3-5 minutes
5. **Visit:** https://cms.jumpstartscaling.com
6. **Success!** ✅

---

## 📋 Quick Checklist

- [ ] Copy SSH key (above)
- [ ] Go to https://github.com/settings/ssh/new
- [ ] Paste key and add to GitHub
- [ ] Tell me it's added
- [ ] I'll push the changes
- [ ] You redeploy in Coolify
- [ ] Site works! 🎉

---

## 🎯 What Will Happen

1. **Push to GitHub** → Commit `c617a7a` goes to GitHub
2. **Coolify redeploys** → Pulls updated code from GitHub
3. **Builds with `push: true`** → New production build
4. **Container starts** → Runs updated code
5. **Database tables exist** → We already created them
6. **Payload CMS works!** → Setup wizard appears ✅

---

## 🆘 Alternative: Manual GitHub Edit

If you prefer not to add SSH key, you can still:

1. **Edit on GitHub:** https://github.com/jumpstartscaling/jumpstartscaling/blob/main/src/payload.config.ts
2. **Add line:** `push: true,` after line 32
3. **Commit** directly on GitHub
4. **Redeploy** in Coolify

---

**Add the SSH key here:** https://github.com/settings/ssh/new

**SSH Key to paste:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcWb1z5SyRmY8UHHC4pqUXyuDOE//mK+OpqAXx0Ei5L deploy@jumpstartscaling.com
```

**Let me know when it's added and I'll push immediately!** 🚀
