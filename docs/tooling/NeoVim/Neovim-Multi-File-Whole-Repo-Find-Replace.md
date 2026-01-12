# Neovim Multi-File Whole-Repo Find/Replace (Case-Sensitive + Case-Insensitive)

This document shows safe, repeatable ways to run find/replace across an entire Git repo in Neovim.
It includes:
- Case-sensitive replacement
- Case-insensitive replacement
- Optional confirm-before-change workflows
- How to handle (or avoid) special-character escaping

------------------------------------------------------------------------------

## Prerequisites / Notes

- You should run these commands from the repo root (or a directory where `**/*` expands to the files you want).
- If your repo is large, consider limiting the file glob (examples below).
- The quickfix list is your friend: it lets you preview matches before editing.
- Always make sure your working tree is clean (or commit first) so you can easily revert if needed.

------------------------------------------------------------------------------

## Workflow A (Recommended): Quickfix-driven replacement using `:vimgrep` + `:cdo`

This workflow is built-in (no plugins needed) and works well for whole-repo edits.

### Step 1: Populate quickfix with matches (Case-SENSITIVE)
```vim
:vimgrep /app-dots/ **/*
:copen
```

### Step 2: Replace across all quickfix entries (Case-SENSITIVE)
```vim
:cdo %s/app-dots/appdots/ge | update
```

- `g` = replace all matches per line
- `e` = do not error if not found in a buffer (safe for multi-file loops)
- `update` = only writes files that actually changed

### Optional: Confirm each replacement (Case-SENSITIVE)
```vim
:cdo %s/app-dots/appdots/gce | update
```

- `c` = confirm each match

------------------------------------------------------------------------------

## Workflow B: Case-INSENSITIVE Replacement (Whole Repo)

In Vim regex, `\c` makes the pattern case-insensitive.

### Step 1: Populate quickfix with matches (Case-INSENSITIVE)
```vim
:vimgrep /\capp-dots/ **/*
:copen
```

### Step 2: Replace across all quickfix entries (Case-INSENSITIVE)
```vim
:cdo %s/\capp-dots/appdots/ge | update
```

### Optional: Confirm each replacement (Case-INSENSITIVE)
```vim
:cdo %s/\capp-dots/appdots/gce | update
```

------------------------------------------------------------------------------

## Limiting Scope (Recommended for Speed + Safety)

You can restrict `**/*` to specific filetypes or directories.

### Only Terraform + YAML files
```vim
:vimgrep /app-dots/ **/*.tf **/*.hcl **/*.yml **/*.yaml
:copen
:cdo %s/app-dots/appdots/ge | update
```

### Only a specific directory subtree
```vim
:vimgrep /app-dots/ terraform/**
:copen
:cdo %s/app-dots/appdots/ge | update
```

------------------------------------------------------------------------------

## Handling Special Characters Safely

Vim’s search pattern uses “very magic” regex rules by default.
Certain characters are special in patterns:
- `.` `*` `[` `]` `(` `)` `{` `}` `^` `$` `\` `|` and more
If your search string contains special characters, you have options:

### Option 1 (Easy): Use `\V` (Very Nomagic) for literal matching
Use `\V` when you want the pattern to be interpreted literally.

#### Literal (Case-SENSITIVE)
```vim
:vimgrep /\Vapp-dots/ **/*
:copen
:cdo %s/\Vapp-dots/appdots/ge | update
```

#### Literal (Case-INSENSITIVE)
Note: put `\c` BEFORE the literal text (it still works).
```vim
:vimgrep /\c\Vapp-dots/ **/*
:copen
:cdo %s/\c\Vapp-dots/appdots/ge | update
```

### Option 2: Escape special characters in the pattern
If you want regex features in general, but need to match a literal `.` or `(` etc, escape them with `\`.
Example: replace `foo.bar` literally
```vim
:vimgrep /foo\.bar/ **/*
:copen
:cdo %s/foo\.bar/foo_bar/ge | update
```

------------------------------------------------------------------------------

## Confirm-First Workflows

You can confirm each match with the `c` flag.
During confirmation, Vim prompts you with choices (like `y/n/a/q/l`).

### Confirm each replacement (Case-SENSITIVE)
```vim
:vimgrep /app-dots/ **/*
:copen
:cdo %s/app-dots/appdots/gce | update
```

### Confirm each replacement (Case-INSENSITIVE)
```vim
:vimgrep /\capp-dots/ **/*
:copen
:cdo %s/\capp-dots/appdots/gce | update
```

------------------------------------------------------------------------------

## Post-Change Verification

After doing the replacement, repopulate quickfix to ensure there are zero matches left.

### Verify (Case-SENSITIVE)
```vim
:vimgrep /app-dots/ **/*
:copen
```

### Verify (Case-INSENSITIVE)
```vim
:vimgrep /\capp-dots/ **/*
:copen
```

------------------------------------------------------------------------------

## Common Pitfalls

- `:cdo` runs on buffers referenced by the quickfix list. If quickfix is empty, nothing happens.
- `update` only writes if the buffer changed; it will not spam writes for untouched files.
- If you accidentally included too many files, use narrower globs (Terraform-only, YAML-only, or a subtree).
- For purely literal matches containing lots of special characters, prefer `\V`.

------------------------------------------------------------------------------

## Quick Copy/Paste Templates

### Case-sensitive, literal-safe, confirm
```vim
:vimgrep /\Vapp-dots/ **/*
:copen
:cdo %s/\Vapp-dots/appdots/gce | update
```

### Case-insensitive, literal-safe, confirm
```vim
:vimgrep /\c\Vapp-dots/ **/*
:copen
:cdo %s/\c\Vapp-dots/appdots/gce | update
```
