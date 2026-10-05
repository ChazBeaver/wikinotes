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
| [`ripgrep`](https://github.com/BurntSushi/ripgrep) | Optional command-line content search | `brew install ripgrep` or `apt install ripgrep` |
| [`bat`](https://github.com/sharkdp/bat)      | Optional command-line file viewing | `brew install bat` or `apt install bat` |
| [`nvim`](https://neovim.io/)                 | Opens Markdown files (or any editor via `$EDITOR`) | `brew install neovim` or `apt install neovim` |

> **Note:** These tools are only required for the search functionality. You can still browse the docs manually without them.

---

## 🚀 Install

Run the install script once per machine to register the repo location and its aliases:

```bash
cd ~/Projects/home/wikinotes
./install.sh
source ~/.dotfiles-env.sh
wikinotes                    # cd into this repo
w                            # open the default picker
```

It persists these lines in `~/.dotfiles-env.sh` (the same file appdots and hyprdots use) and is safe to re-run; a moved repo just updates the path:

| Line | Purpose |
|------|---------|
| `export WIKINOTES_DIR=...` | Absolute path to this repo |
| `alias wikinotes` | `cd` straight into the repo |
| `alias w` | Run `scripts/wiki.sh` (fuzzy search) from anywhere |

Open a new shell afterwards, or `source ~/.dotfiles-env.sh`.

---

## 📁 Project Structure

- `docs/` – All documentation organized by topic
- `examples/` – Standalone scripts, helper files, and reusable snippets
- `scripts/` – Utility scripts for local use (e.g., fuzzy search)

---

## 🔍 Local Search

The pickers index Markdown under `docs/` and `examples/` only. Private
`notes/` are deliberately excluded. They search filenames; use `rg` below
to search file contents. No index-build step is needed after an edit.

From the repo root, choose one of these entrypoints:

```bash
EDITOR=nvim bash scripts/wiki.sh       # plain-text preview; Enter opens in editor
EDITOR=vi bash scripts/wiki-lite.sh    # headings preview; Enter, then y to edit
bash scripts/wiki-glow.sh              # rendered Markdown preview and Glow pager
```

All three require `fzf`, `find`, `sed`, `awk`, and `cut`. The default picker
uses `cat`; lite also uses `grep`. Neither requires `bat` or `ripgrep`.
The Glow variant requires `glow` (for example, `brew install glow` on macOS
or `omarchy pkg add glow` on Omarchy). It reads the selection instead of
opening `$EDITOR`. Press `q` to leave the Glow pager.

Type a filename query, use the arrow keys to select, and press Enter. Press
Esc or Ctrl-C to cancel; with the current scripts this can return a nonzero
status. The scripts take no positional query argument and have no `--help`
mode. Use `EDITOR=vi` or another installed editor if `nvim` is unavailable.

Search contents or open a known file without a picker:

```bash
cd ~/Projects/home/wikinotes
rg -n -i 'kubernetes' docs examples
rg -l -i 'kubernetes' docs examples | fzf --preview 'cat {}'
nvim examples/bash/bash-kubernetes-k8s-examples.md
rg --files notes             # explicitly browse private planning material
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

Run the lite picker from another directory without adding another alias:

```bash
bash "$WIKINOTES_DIR/scripts/wiki-lite.sh"
```

## Manual maintenance and hook audit

Update an installed checkout:

```bash
cd ~/Projects/home/wikinotes
git status --short
git pull --ff-only
./install.sh                 # also repairs aliases after moving the checkout
source ~/.dotfiles-env.sh
```

The installer prints the repo path and confirms both aliases. Its repair
branches currently use GNU `sed -i`; on macOS, if an existing entry needs
changing, use GNU sed for this invocation:

```bash
brew install gnu-sed
PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH" ./install.sh
```

To add searchable content manually, create a topic directory and a Markdown
file using the naming convention below, then verify it appears in the picker:

```bash
mkdir -p docs/bash
nvim docs/bash/bash-pipelines-walkthrough.md
bash scripts/wiki.sh         # type bash-pipelines; Enter opens the saved file
```

Keep private plans under `notes/`; those files are read directly in an editor.
The repository has no `doctor.sh` or automated test suite. To verify a change,
check each script with its interpreter, then exercise the picker you changed:

```bash
for wiki_script in install.sh scripts/wiki.sh scripts/wiki-lite.sh scripts/wiki-glow.sh; do
  bash -n "$wiki_script" || break
done
zsh -n scripts/git-hook-dir-audit.sh
```

The remaining utility is a read-only Git hook audit. Despite its `.sh`
extension, it requires **Zsh**, not Bash:

```bash
zsh scripts/git-hook-dir-audit.sh ~/Projects/home
zsh scripts/git-hook-dir-audit.sh ~/Projects/home ~/Projects/work
```

Supply parent directories containing repositories. It reports the global
`core.hooksPath`, per-repo overrides, and executable non-sample hooks under
`.git/hooks`. It does not enable or change hooks. Its scan of `.git/hooks`
does not resolve linked-worktree `.git` files or inspect the contents of a
custom hooks directory. No arguments prints usage and exits 2.

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
