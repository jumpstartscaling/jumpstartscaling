# SSH Connection Issue

I'm unable to connect to the Oracle server with the SSH keys found in `~/.ssh/oracle_ubuntu`.

## Current Situation

- **Server:** opc@193.122.168.215
- **Key tried:** ~/.ssh/oracle_ubuntu
- **Error:** Permission denied (publickey)

## Possible Solutions

### Option 1: Check if the SSH key is registered on the server

The `oracle_ubuntu` key might not be registered with the Oracle server. You may need to:

1. Add the public key to the server's `~/.ssh/authorized_keys`
2. Or use a different SSH key that's already registered

### Option 2: Use a different SSH key

According to your documentation, you have several SSH keys:
- `~/.ssh/google_compute_engine` (mentioned as alternate for Oracle)
- `~/.ssh/id_ed25519`
- `~/.ssh/id_rsa`

### Option 3: Manual Installation

You can install Stream-Rec manually by SSH'ing to the server yourself and running commands directly.

## What I Need From You

1. **Can you SSH to the Oracle server manually?**
   ```bash
   ssh opc@193.122.168.215
   ```

2. **Which SSH key or method do you use?**

3. **Would you like me to:**
   - Try a different SSH key?
   - Provide manual installation commands you can run?
   - Help you set up the SSH key?

## Temporary Workaround - Manual Installation

If you can SSH to the server, here are the commands to run:

```bash
# On your Mac, sync files manually
rsync -av --exclude 'downloads' --exclude 'rclone' \
  ~/Downloads/spark/god-mode/stream-rec/ \
  opc@193.122.168.215:/home/opc/stream-rec/

# Then SSH to server
ssh opc@193.122.168.215

# On the server
cd /home/opc/stream-rec
mkdir -p downloads rclone
docker compose pull
docker compose up -d
```

Let me know how you'd like to proceed!
