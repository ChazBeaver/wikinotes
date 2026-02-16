# 🚀 Steps to Create an SSH Key and Add It to GitHub
*(With Clear Naming & Path Guidance)*

---

## 1️⃣ Open a Terminal

Make sure you are in **any directory** — your home directory is fine, but this works anywhere.

---

## 2️⃣ Generate an SSH Key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

You will see a prompt like:

```text
Enter file in which to save the key (/home/you/.ssh/id_ed25519):
```

### ✅ Recommended (Simplest & Safest Option)

Press **Enter** to accept the default:

```text
~/.ssh/id_ed25519
```

This ensures:
- The key is saved in the correct directory (`~/.ssh/`)
- Future commands work exactly as documented

---

### ⚠️ Important: Custom Names & Path Syntax (READ THIS)

If you type **only a filename**, for example:

```text
custom_key_name
```

⚠️ **That filename is treated as a _relative path_**
➡️ The key will be created in your **current working directory**, NOT `~/.ssh/`.

Example (what NOT to do unless intentional):

```text
Enter file in which to save the key: custom_key_name
```

Result:

```text
./custom_key_name
./custom_key_name.pub
```

These files will **not** be in `~/.ssh/`, which often causes confusion later.

---

### ✅ Correct Way to Use a Custom Name

If you want a custom name **and** want the key in `~/.ssh/`, you must include the full or expanded path:

```text
Enter file in which to save the key: ~/.ssh/custom_key_name
```

✔ This creates:

```text
~/.ssh/custom_key_name
~/.ssh/custom_key_name.pub
```

---

### 🔑 Passphrase

- Optional, but **recommended**
- Adds protection if the key is ever stolen

---

## 3️⃣ Start the SSH Agent

```bash
eval "$(ssh-agent -s)"
```

You should see output like:

```text
Agent pid 1234
```

---

## 4️⃣ Add Your SSH **Private** Key to the Agent

⚠️ You must add the **private key** (NO `.pub` extension):

```bash
ssh-add ~/.ssh/custom_key_name
```

❌ This will NOT work:

```bash
ssh-add ~/.ssh/custom_key_name.pub
```

---

### 🔍 Verify the Key Was Added

```bash
ssh-add -l
```

You should see an `ED25519` key listed.

---

## 5️⃣ Copy Your Public Key

```bash
cat ~/.ssh/custom_key_name.pub
```

Copy the entire output (starts with `ssh-ed25519`).

### Clipboard shortcuts:

**macOS**
```bash
pbcopy < ~/.ssh/custom_key_name.pub
```

**Linux**
```bash
xclip -sel clip < ~/.ssh/custom_key_name.pub
```

**Omarchy**
```bash
cat ~/.ssh/custom_key_name.pub | wl-copy
```
---

## 6️⃣ Add the SSH Key to GitHub

1. Go to:
   https://github.com/settings/keys
2. Click **New SSH key**
3. Fill in:
   - **Title**: Something descriptive (e.g., Laptop, Desktop, Arch System)
   - **Key**: Paste the public key
4. Save

---

## 7️⃣ (Optional but Recommended) Configure SSH to Always Use This Key

Create or edit `~/.ssh/config`:

```sshconfig
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/custom_key_name
  IdentitiesOnly yes
```

This prevents SSH from guessing or using the wrong key.

---

## 8️⃣ Test the SSH Connection

```bash
ssh -T git@github.com
```

Expected success message:

```text
Hi your-username! You've successfully authenticated...
```

---

## 📦 You Can Now Use Git Over SSH

Example:

```bash
git clone git@github.com:your-username/your-repo.git
git push
git pull
```

---

## 🧪 Extra Debug (If Something Breaks)

```bash
ssh -vT git@github.com
```

This shows:
- Which keys are being tried
- Whether the SSH agent is working
- Where authentication fails

---

## 🧠 Key Takeaway (Critical)

**If you do not explicitly include `~/.ssh/` when naming a key, it will be created in your current directory.**
This is the #1 cause of “No such file or directory” errors with `ssh-add`.
