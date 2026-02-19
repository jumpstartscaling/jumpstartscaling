# 🔑 ADD SSH KEY TO GITHUB & PUSH

## Step 1: Add SSH Key to GitHub

**Copy this SSH public key:**

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcWb1z5SyRmY8UHHC4pqUXyuDOE//mK+OpqAXx0Ei5L deploy@jumpstartscaling.com
```

**Add it to GitHub:**

1. **Go to:** https://github.com/settings/keys
2. **Click:** "New SSH key"
3. **Title:** `Coolify Server - Payload CMS`
4. **Key:** Paste the key above
5. **Click:** "Add SSH key"

## Step 2: Push the Changes

After adding the key to GitHub, run this command:

```bash
ssh -i ~/.ssh/id_rsa opc@193.122.168.215 'cd /home/opc/payload-multitenant && GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git push origin main'
```

Or I can run it for you once you confirm the key is added to GitHub.

---

## Quick Link

**Add SSH key here:** https://github.com/settings/ssh/new

**Key to paste:**
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPcWb1z5SyRmY8UHHC4pqUXyuDOE//mK+OpqAXx0Ei5L deploy@jumpstartscaling.com
```

---

**Let me know when you've added the key, and I'll push the changes!** 🚀
