# Safe Git Merge Resolution: Keep `origin/main` on Conflicts, Control `CHANGELOG.md`

## Purpose
This guide documents the exact, safe workflow discussed for merging `origin/main` into a feature branch
while ensuring that:
- All files you did NOT work on always keep the version from `origin/main`.
- You never accidentally reintroduce or overwrite someone else’s work.
- `CHANGELOG.md` is the only file you may manually resolve during conflicts.
- Your merge request (MR) proposes ONLY your intended changes.

This write-up is intentionally explicit and defensive.

---------------------------------------------------------------------

## Mental Model (Critical to Understand)

- Merging `origin/main` updates YOUR branch only.
- Pushing YOUR branch does NOT modify `main`.
- The only way to affect others is if your MR proposes unintended diffs
  and that MR is merged.
- Therefore, safety = verifying your diff vs `origin/main`.

---------------------------------------------------------------------

## Pre-flight Checks

### 1) Ensure you are NOT mid-merge
```bash
git status
```
- If you see “You are still merging”, you must finish or abort before continuing.

### 2) Ensure a clean working tree
```bash
git status
```
- You must see: “working tree clean”.

### 3) Fetch the latest remote state
```bash
git fetch origin
```

---------------------------------------------------------------------

## Safe Merge Strategy

### Goal
Merge all of `origin/main` into your branch while ensuring that
any conflicts default to MAIN’s version, not yours.

### 4) Merge `origin/main`, preferring main on conflicts
```bash
git merge -X theirs origin/main
```

Explanation:
- `-X theirs` applies to the default `ort` merge strategy.
- For conflicted hunks, Git automatically chooses `origin/main`.
- Non-conflicted files are merged normally.

---------------------------------------------------------------------

## Handling Conflicts Safely

### 5) Identify remaining conflicts (if any)
```bash
git status
git diff --name-only --diff-filter=U
```

### 6) Force MAIN’s version for all conflicted files EXCEPT `CHANGELOG.md`
```bash
git diff --name-only --diff-filter=U | grep -v '^CHANGELOG\.md$' | xargs -r git checkout --theirs --
git diff --name-only --diff-filter=U | grep -v '^CHANGELOG\.md$' | xargs -r git add --
```

This guarantees that you cannot accidentally keep an outdated version
of any file you did not explicitly work on.

### 7) Resolve `CHANGELOG.md` manually
```bash
$EDITOR CHANGELOG.md
git add CHANGELOG.md
```

### 8) Complete the merge
```bash
git commit
```

---------------------------------------------------------------------

## Mandatory Safety Verification (DO NOT SKIP)

### 9) Confirm your branch contains `origin/main`
```bash
git merge-base --is-ancestor origin/main HEAD && echo "OK: origin/main is included"
```

### 10) Verify MR “blast radius” (what your MR will change)
```bash
git diff --name-status origin/main...HEAD
```

Interpretation:
- This list must include ONLY:
  - Files you intentionally changed
  - `CHANGELOG.md` (if modified)
- If extra files appear, STOP and investigate before pushing.

### 11) Review actual content changes (optional but recommended)
```bash
git diff origin/main...HEAD
```

### 12) Review commits your MR will introduce
```bash
git log --oneline --decorate origin/main..HEAD
```

---------------------------------------------------------------------

## Push (Safe Operation)

### 13) Push your feature branch
```bash
git push origin <your-branch-name>
```

Reminder:
- This does NOT modify `main`.
- Only merging the MR modifies `main`.

---------------------------------------------------------------------

## Common Confusions Explained

### “Why did files I didn’t touch show up during the merge?”
- Because those files changed on `origin/main`.
- The merge brings them into your branch so history aligns.
- This is expected and correct behavior.

### “Did I overwrite someone else’s work?”
- No. You only updated your branch.
- The safety check (`git diff origin/main...HEAD`) ensures
  you are not proposing unintended reversions.

### “Why did I see hundreds of files during the merge?”
- That output describes the merge commit summary.
- It does NOT mean your MR proposes all those changes.
- Only `git diff origin/main...HEAD` defines MR scope.

---------------------------------------------------------------------

## Escape Hatches

### Abort merge (only if merge is in progress)
```bash
git merge --abort
```

### Rebuild branch cleanly from `origin/main`
```bash
git branch backup/<branch-name>
git reset --hard origin/main
git cherry-pick <your-commit-sha>
git push --force-with-lease origin <branch-name>
```

---------------------------------------------------------------------

## Quick Reference

### Merge main safely
```bash
git fetch origin
git merge -X theirs origin/main
```

### Verify MR contents
```bash
git diff --name-status origin/main...HEAD
```

### Golden Rule
If the diff vs `origin/main` looks correct, your MR is safe.
Always trust the diff, never assumptions.
