# GitHub SSH Authentication Setup Guide

## Step 1: Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "derli@healthmonitor.com"
# Press Enter to accept default location
# Press Enter twice for empty passphrase (or add one for security)
```

## Step 2: Copy SSH Public Key
```bash
cat ~/.ssh/id_ed25519.pub
# Copy the entire output (starts with ssh-ed25519)
```

## Step 3: Add SSH Key to GitHub
1. Go to: https://github.com/settings/ssh
2. Click "New SSH key"
3. Paste your public key
4. Click "Add SSH key"

## Step 4: Switch to SSH Remote
```bash
cd "C:\Users\derli\your-awesome-project"
git remote set-url origin git@github.com:derlinshaju2/health-app.git
git push origin main
```

## Step 5: Test Connection
```bash
ssh -T git@github.com
# Should show: "Hi derlinshaju2! You've successfully authenticated..."
```

## Benefits of SSH:
- ✅ No need for tokens/passwords
- ✅ More secure than HTTPS
- ✅ Works better with firewalls/proxies
- ✅ No credential expiration issues