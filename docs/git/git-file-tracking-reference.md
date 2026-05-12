# Git File Tracking Reference

A guide for controlling how git tracks (or ignores) files in your repo.

---

## Quick Decision Guide

| Situation | Solution |
|---|---|
| File was never tracked; you never want it tracked | `.gitignore` |
| File is tracked; you want local changes ignored temporarily | `--assume-unchanged` |
| File is tracked; you want a permanent local override (e.g. config) | `--skip-worktree` |
| File is tracked; you want to fully stop tracking it everywhere | `git rm --cached` |

---

## 1. `.gitignore` — Never Track a File

Use this for files that **have never been committed** and should never be. Examples: `.env`, `node_modules/`, build artifacts, OS files.

### How to use

Add the file or pattern to `.gitignore`:

```
# .gitignore
.env
*.log
node_modules/
dist/
.DS_Store
```

Then commit `.gitignore` itself:

```bash
git add .gitignore
git commit -m "Update .gitignore"
```

### ⚠️ Gotcha

`.gitignore` **has no effect on already-tracked files.** If the file is already in git's history, you must use `git rm --cached` (see section 4) first.

---

## 2. `--assume-unchanged` — Locally Ignore Changes to a Tracked File

Use this as a **performance hint** when you don't intend to modify a file but want it to remain in the repo. Git will skip checking it for changes.

### How to use

```bash
git update-index --assume-unchanged <file>
```

### To reverse it

```bash
git update-index --no-assume-unchanged <file>
```

### To see all assume-unchanged files

```bash
git ls-files -v | grep '^[a-z]'
# Lowercase letter prefix = assume-unchanged
```

### Behavior

- Git skips the file during `git status` and `git diff`
- **Not safe across pulls** — if the remote changes the file, git may overwrite your version without warning
- The flag is **local only** — it lives in `.git/index` and is not shared with other contributors
- Best for: large generated files, binaries, files you never touch

---

## 3. `--skip-worktree` — Persist a Local Override of a Tracked File

Use this when you **intentionally want a local version** of a tracked file that differs from the repo. Common for config files with environment-specific values.

### How to use

```bash
git update-index --skip-worktree <file>
```

### To reverse it

```bash
git update-index --no-skip-worktree <file>
```

### To see all skip-worktree files

```bash
git ls-files -v | grep '^S'
# Capital S prefix = skip-worktree
```

### Behavior

- Git respects your local version and won't flag it as modified
- **Safer than `--assume-unchanged` across pulls** — git will warn you (or refuse) before clobbering your local version
- Also **local only** — not committed or shared
- Best for: `config.json`, `.env.local`, any file with values that differ per machine

---

## 4. `git rm --cached` — Stop Tracking a File That's Already Committed

Use this to **fully remove a file from git tracking** while keeping it on disk. After this, you can add it to `.gitignore` so it stays untracked going forward.

### How to use

```bash
git rm --cached <file>
echo "<file>" >> .gitignore
git add .gitignore
git commit -m "Stop tracking <file>"
```

For a directory:

```bash
git rm -r --cached <directory>/
```

### Behavior

- The file disappears from the repo for everyone on the next pull
- The file remains on your local disk untouched
- Other contributors will have the file **deleted** from their working tree on next pull (since it's no longer in the repo) — give them a heads-up
- The file will still exist in git history; it's not scrubbed from the past

---

## Summary Comparison

| Method | File must be untracked? | Local only? | Safe on pull? | Use case |
|---|---|---|---|---|
| `.gitignore` | Yes (or use `rm --cached` first) | No (committed) | Yes | Never track this file |
| `--assume-unchanged` | No | Yes | ⚠️ No | Perf hint; I won't modify this |
| `--skip-worktree` | No | Yes | ✅ Mostly | I want my own local version |
| `git rm --cached` | No | No (affects all) | N/A | Stop tracking for everyone |

---

## Common Workflow: Config File with Local Overrides

```bash
# 1. File is already tracked (e.g. config.json)
# 2. Tell git to ignore your local changes
git update-index --skip-worktree config.json

# 3. Now edit config.json freely — git won't notice
# 4. To push a change to the base config, reverse the flag first
git update-index --no-skip-worktree config.json
git add config.json
git commit -m "Update base config"
git update-index --skip-worktree config.json
```
