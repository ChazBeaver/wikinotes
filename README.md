# 🛠️ Wiki-Notes

Welcome to **Wiki-Notes** — my personal DevOps knowledge base.

This repository contains curated notes, walkthroughs, cheat sheets, and reusable code snippets I’ve written or collected over time.
The goal is to document workflows, commands, and concepts that I don’t use frequently enough to memorize —
and to make them instantly searchable with tools like [`fzf`](https://github.com/junegunn/fzf) and [`ripgrep`](https://github.com/BurntSushi/ripgrep).

---

## 🧩 Dependencies

To use the full functionality of `Wiki-Notes`, make sure the following tools are installed on your system:

| Tool      | Purpose                         | Install Reference                              |
|-----------|----------------------------------|------------------------------------------------|
| [`fzf`](https://github.com/junegunn/fzf)     | Fuzzy file selection and preview               | [`brew install fzf`](https://github.com/junegunn/fzf#using-homebrew) or [`apt install fzf`](https://github.com/junegunn/fzf#debianubuntu) |
| [`ripgrep`](https://github.com/BurntSushi/ripgrep) | Fast text search inside files           | `brew install ripgrep` or `apt install ripgrep` |
| [`bat`](https://github.com/sharkdp/bat)      | Syntax-highlighted file previews (optional)    | `brew install bat` or `apt install bat` |
| [`nvim`](https://neovim.io/)                 | Opens Markdown files (or any editor via `$EDITOR`) | `brew install neovim` or `apt install neovim` |

> **Note:** These tools are only required for the search functionality. You can still browse the docs manually without them.

---

## 📁 Project Structure

- `docs/` – All documentation organized by topic
- `examples/` – Standalone scripts, helper files, and reusable snippets
- `scripts/` – Utility scripts for local use (e.g., fuzzy search)

---

## 🔍 Local Search

Quickly search through notes and files using `fzf`:

```bash
bash scripts/wiki.sh
```

Or grep through contents with preview:

```bash
rg "<keyword>" docs examples | fzf --preview 'bat --style=numbers --color=always --line-range :100 {1}'
```

---

## 🪶 Lightweight Option

If you prefer not to install `bat` or `ripgrep`, you can use the lighter version of the search script:

```bash
bash scripts/wiki-lite.sh
```

This version uses only `find`, `cat`, `grep`, and `fzf`.

It previews headings inside the selected Markdown file (using `grep '^#'`) and optionally opens the file using your default `$EDITOR`.

### Example Output
```
================= Preview: docs/git/github-ssh-setup.md ================
# Setting up SSH with GitHub
## Step 1: Generate key
## Step 2: Add key to ssh-agent
## Step 3: Add key to GitHub
========================================================================
Open in editor? [y/N]:
```

You can also create an alias for convenience:

```bash
alias wikilite="$WIKINOTES_DIR/scripts/wiki-lite.sh"
```

---

## 🗂 File Naming Convention

Each Markdown file follows this naming pattern:

```
<topic>-<scope>.md
```

Examples:

- `gitlab-pipeline-snippets.md`
- `kubernetes-network-policy-overview.md`
- `bash-script-templates.md`

This makes each file easy to identify and search using `fzf`, `ls`, or `rg`.

### ✅ Recommended Title Tags

#### 🧠 Conceptual & Descriptive
- `overview`
- `concepts`
- `terminology`
- `comparison`
- `workflow`
- `patterns`
- `gotchas`
- `faq`
- `troubleshooting`

#### ⚙️ Procedural & Practical
- `setup`
- `walkthrough`
- `guide`
- `howto`
- `install`
- `migration`
- `update`
- `integration`

#### 🧪 Code & Command-Oriented
- `snippets`
- `examples`
- `templates`
- `commands`
- `cheatsheet`
- `functions`
- `aliases`

#### 🔗 Reference & Support
- `links`
- `resources`
- `metadata`
- `config`
- `schema`
- `env-vars`

---

## 📚 Topics Covered (growing)

- Git, GitHub, GitLab workflows
- Kubernetes (kubectl, manifests, ArgoCD)
- Bash scripting and shell patterns
- CI/CD and infrastructure tooling
- Tools like `jq`, `yq`, `fzf`, and more

---

## 🚀 Contributions

This project is for personal use, but feel free to fork or adapt it for your own workflows.
