# Stop Tracking Files and Update `.gitignore`

This guide shows how to remove files from Git tracking while keeping
them on disk, then commit and push the changes.

---

## Remove files from tracking (files remain locally)
```bash
git rm --cached path/to/file1
git rm --cached path/to/file2
```

---

## Update `.gitignore`
Add the following entries to your `.gitignore` file

```gitignore
path/to/file1
path/to/file2
```

---

## Verify staged changes
```bash
git status
```

You should see:
- `D` for the removed files
- `M` for `.gitignore`

---

## Commit the changes
```bash
git commit -m "Stop tracking local files and update gitignore"
```

---

## Push to remote
```bash
git push
```

---

After this commit, the files will exist locally but Git will no longer
track or report changes to them.
