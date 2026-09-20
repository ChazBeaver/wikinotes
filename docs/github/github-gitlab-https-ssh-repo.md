# Git Remote URL: Switch Between HTTPS and SSH

## Why switch?
- **HTTPS**: works everywhere; authenticates with **PAT/token** (GitHub/GitLab) or username/password (rare now).
- **SSH**: no token prompts during push/pull (after setup); uses your **SSH key** and `~/.ssh/config`.

---

## 1) Check what your repo is using now

```bash
git remote -v
```

Typical formats:

**HTTPS**
- `https://github.com/OWNER/REPO.git`
- `https://gitlab.com/GROUP/REPO.git`

**SSH**
- `git@github.com:OWNER/REPO.git`
- `git@gitlab.com:GROUP/REPO.git`

---

## 2) Switch HTTPS ➜ SSH

### GitHub
```bash
git remote set-url origin git@github.com:OWNER/REPO.git
```

### GitLab
```bash
git remote set-url origin git@gitlab.com:GROUP/REPO.git
```

### Verify
```bash
git remote -v
```

### Test SSH authentication
**GitHub**
```bash
ssh -T git@github.com
```

**GitLab**
```bash
ssh -T git@gitlab.com
```

---

## 3) Switch SSH ➜ HTTPS

### GitHub
```bash
git remote set-url origin https://github.com/OWNER/REPO.git
```

### GitLab
```bash
git remote set-url origin https://gitlab.com/GROUP/REPO.git
```

### Verify
```bash
git remote -v
```

---

## 4) Common “gotchas” and quick checks

### A) You changed the remote but it still prompts for username/password
That almost always means **something is still using HTTPS**, like:
- another remote (e.g., `upstream`)
- submodules
- a second repo URL in tooling/scripts

Check all remotes:
```bash
git remote -v
```

Check submodule URLs (if you use submodules):
```bash
git config --file .gitmodules --get-regexp url
```

### B) SSH key issues
Your `IdentityFile` should point to the **private key**, not `.pub`.

✅ `~/.ssh/id_ed25519_something`
❌ `~/.ssh/id_ed25519_something.pub`

Quick debug:
```bash
ssh -Tv git@github.com
```

---

## 5) Optional: “Convert” URL patterns quickly

### GitHub
- HTTPS → SSH
  `https://github.com/OWNER/REPO.git` → `git@github.com:OWNER/REPO.git`
- SSH → HTTPS
  `git@github.com:OWNER/REPO.git` → `https://github.com/OWNER/REPO.git`

### GitLab
- HTTPS → SSH
  `https://gitlab.com/GROUP/REPO.git` → `git@gitlab.com:GROUP/REPO.git`
- SSH → HTTPS
  `git@gitlab.com:GROUP/REPO.git` → `https://gitlab.com/GROUP/REPO.git`

---

If you tell me **GitHub vs GitLab** (or paste `git remote -v`), I can return the exact one-liners for your repo with your real remote names.
