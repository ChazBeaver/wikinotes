# 🔐 GitLab Personal Access Token (PAT) + EC2 HTTPS Clone Guide

This guide walks you through:
- 🔒 Creating a GitLab Personal Access Token (PAT)
- 🖥️ Using that PAT on an EC2 instance
- 📦 Cloning repositories over HTTPS securely

---

## 🔒 Step 1: Create a GitLab Personal Access Token (PAT)

1. Log into your GitLab instance (e.g., https://gitlab.com or your internal GitLab URL).
2. Navigate to:
   - Profile icon (top right)
   - Preferences / Edit Profile
   - Access Tokens
3. Fill out the token details:
   - **Name**: e.g., `ec2-clone-access`
   - **Expiry date**: optional but recommended
   - **Scopes**:
      ✅ `read_repository` (required for cloning)
      ✅ `write_repository` (optional, for pushing)
      ✅ `api` (optional, only if needed for automation/scripts)
4. Click **Create personal access token**
5. ⚠️ IMPORTANT: Copy and securely store the token
   - You will NOT be able to view it again

---

## 🖥️ Step 2: Connect to Your EC2 Instance

Use SSH to access your EC2 instance:

```bash
ssh ec2-user@your-ec2-public-ip
```

Or for Ubuntu-based AMIs:

```bash
ssh ubuntu@your-ec2-public-ip
```

Ensure:
- Your security group allows SSH (port 22)
- Your key pair is configured correctly

---

## 📦 Step 3: Clone a GitLab Repo Using HTTPS + PAT

Use the HTTPS clone URL for your repository:

```bash
git clone https://gitlab.com/your-username/your-repo.git
```

When prompted for credentials:

- **Username**: your GitLab username
- **Password**: paste your PAT (NOT your GitLab password)

Example:

```bash
Username: your-username
Password: glpat-xxxxxxxxxxxxxxxx
```

---

## 🔐 Step 4: Avoid Re-entering Your PAT (Credential Helper)

To prevent entering your PAT repeatedly, configure Git credential storage.

### Option A: Cache credentials temporarily

```bash
git config --global credential.helper cache
```

This stores credentials in memory (default ~15 minutes).

---

### Option B: Store credentials in plaintext (use with caution)

```bash
git config --global credential.helper store
```

This saves credentials to:

```bash
~/.git-credentials
```

⚠️ WARNING: This stores your PAT in plain text. Only use in secure environments.

---

## 📁 Step 5: Use a .netrc File (Recommended for Automation)

Instead of interactive login, you can store credentials in a `.netrc` file:

1. Create the file:

```bash
nano ~/.netrc
```

2. Add the following:

```txt
machine gitlab.com
login your-username
password glpat-xxxxxxxxxxxxxxxx
```

3. Secure the file:

```bash
chmod 600 ~/.netrc
```

This allows Git to authenticate automatically over HTTPS.

---

## 🔍 Step 6: Verify Your Remote Configuration

Confirm your repo is using HTTPS:

```bash
git remote -v
```

Expected output:

```bash
origin  https://gitlab.com/your-username/your-repo.git (fetch)
origin  https://gitlab.com/your-username/your-repo.git (push)
```

---

## 🛠️ Troubleshooting

❌ Authentication failed
- Ensure you're using the PAT instead of your password
- Verify the PAT has correct scopes

❌ Repo not found
- Confirm the URL is correct
- Ensure your account has access

❌ Permission denied
- Check token scopes
- Check group/project permissions

---

## ✅ Final Notes

- PATs are required for HTTPS authentication with GitLab
- Never hardcode PATs into scripts or repositories
- Rotate tokens regularly for security
- Prefer `.netrc` or credential helpers for automation

You are now set up to securely clone GitLab repositories from an EC2 instance using HTTPS + PAT 🚀
