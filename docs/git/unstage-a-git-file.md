# Unstage a File Accidentally Added with `git add .`

This guide shows how to remove a single file from the staging area
without deleting the file or losing local changes.

---

## Check current staged files
```bash
git status
```

---

## Unstage a single file (recommended)
```bash
git restore --staged path/to/file
```

Example
```bash
git restore --staged config/secrets.yaml
```

---

## Verify
```bash
git status
```

The file should now appear as modified but not staged.
