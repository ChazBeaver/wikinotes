# Writing Optimal Agent Skills

A practical manual for building skills that Claude Code, OpenAI Codex, and OpenCode
will actually pick up and use well. Everything here is self-contained. The examples
are complete and can be copied as-is.

---

## 1. What a skill is

A skill is a folder containing a `SKILL.md` file and, optionally, supporting files
(reference docs, scripts, templates). The harness reads it in three stages, and each
stage costs context:

| Stage | What is loaded | When |
|---|---|---|
| 1. Discovery | `name` + `description` from frontmatter | Every session, for every installed skill |
| 2. Activation | The body of `SKILL.md` | Only when the model or user invokes the skill |
| 3. On demand | Reference files, scripts, templates | Only when the body points at them for the current task |

This is called **progressive disclosure**, and every rule in this document follows
from it:

- The **description** does the routing. It is the only text in play when the model
  decides whether to use the skill.
- The **body** does the workflow. It is read once the decision is made.
- The **supporting files** hold the depth. They are read only when needed.

A skill is different from `CLAUDE.md` / `AGENTS.md`. Those files are always loaded
and hold project-wide conventions. A skill is for a workflow or body of knowledge
that is only *sometimes* relevant.

---

## 2. Anatomy of a skill folder

```
my-skill/
├── SKILL.md            # required: frontmatter + instructions
├── reference/          # optional: deep docs, loaded on demand
│   ├── topic-a.md
│   └── topic-b.md
├── scripts/            # optional: deterministic helpers the model runs
│   └── check.sh
└── templates/          # optional: files the model copies or fills in
    └── output.md
```

Rules:

- The folder name **is** the skill name. Use lowercase kebab-case: `release-notes`,
  `db-migration`, `api-client-conventions`.
- `SKILL.md` must be at the folder root, spelled exactly that way.
- Everything else is optional. Add a supporting file only when `SKILL.md` would
  otherwise exceed ~500 lines or when a step is deterministic enough to script.

---

## 3. The frontmatter

`SKILL.md` starts with a YAML block. Two fields are required; the rest are optional.

### Portable fields (all harnesses)

| Field | Required | Purpose |
|---|---|---|
| `name` | yes | Must match the folder name. Lowercase, hyphens, no spaces. |
| `description` | yes | What it does, when to use it, what it excludes. See section 4. |
| `license` | no | SPDX identifier if you share the skill. |
| `compatibility` | no | Free text noting required tools or environments. |
| `metadata` | no | String-to-string map for your own bookkeeping (owner, version). |

### Claude Code extensions

These are honored by Claude Code and silently ignored by Codex and OpenCode. Using
them is safe; **depending** on them for correctness is not.

| Field | Purpose |
|---|---|
| `disable-model-invocation: true` | Only a human can invoke it via `/name`. Use for anything with side effects: commit, deploy, send a message. |
| `user-invocable: false` | Only the model can invoke it. Use for background knowledge that is not a command. |
| `allowed-tools` | Tools that may run without per-use approval while the skill is active. |
| `argument-hint` | Placeholder text shown after `/name` in the UI, e.g. `[ticket-id]`. |
| `context: fork` | Run the skill in a forked subagent so its output stays out of the main context. |
| `model` | Override the model for this skill. |

Minimal valid frontmatter:

```yaml
---
name: release-notes
description: >
  Generates release notes from merged PRs between two git tags.
  Use when asked to "write release notes", "draft the changelog", "what shipped
  since vX", or before cutting a release. Does not create the tag or publish.
---
```

---

## 4. Writing the description

This is the highest-leverage text in the skill. Skills fail here far more often than
in the body. Write it to answer three questions in this order:

1. **What it does.** One clause, third person, present tense.
2. **When to use it.** Concrete triggers: the words a user actually types, file
   paths, commands, error strings. Lists of trigger words route better than prose.
3. **What it excludes.** One negative boundary so it does not fire on adjacent work.

Keep it under ~400 characters. Every installed skill pays this cost every session.

### Bad description

```yaml
description: A helpful skill for working with databases and migrations in our app.
```

Problems: no triggers, no boundary, "helpful" says nothing, "our app" is meaningless
to the model.

### Good description

```yaml
description: >
  Creates and reviews SQL migration files for the Postgres schema in db/migrations/.
  Use when asked to "add a column", "create a table", "write a migration", "change
  the schema", or when editing any file under db/migrations/. Triggers: migration,
  schema, ALTER TABLE, index, foreign key, backfill. Does not run migrations against
  production.
```

### Checklist

- [ ] Starts with a verb phrase describing the outcome, not "This skill..."
- [ ] Names at least three literal phrases a user would type
- [ ] Names file paths or commands if the skill is tied to them
- [ ] Ends with one exclusion
- [ ] Under 400 characters

---

## 5. Writing the body

The body is instructions to a capable colleague who already knows the tools. It is
not a tutorial and not documentation for humans.

- **Imperative voice, numbered steps.** "Run X. Check Y. If Z, read `reference/a.md`."
- **Put the essential procedure first.** If the model reads only the top 40 lines,
  it should still succeed on the common case.
- **Keep it under ~500 lines.** Past that, split by topic into `reference/` and add
  a short index section pointing to each file with one line on when to read it.
- **Script deterministic steps.** If a step is "parse this and compute that", ship a
  script in `scripts/` and tell the model to run it. Scripts are cheaper, faster,
  and more reliable than reasoning through the same thing every time.
- **State the done condition.** Tell it what finished looks like and what to report.
- **State what not to do.** A short "Never" list prevents the most common mistakes.
- **Do not restate what is in `CLAUDE.md` / `AGENTS.md`.** It is already loaded.

---

## 6. Worked example A: an auto-invoked workflow skill

This skill is triggered by the model when the user asks for release notes. It has a
reference file for the house style and a script for the deterministic part.

### `release-notes/SKILL.md`

```markdown
---
name: release-notes
description: >
  Generates release notes from merged PRs between two git tags or refs.
  Use when asked to "write release notes", "draft the changelog", "what shipped
  since vX", "summarize this release", or before cutting a release.
  Does not create tags or publish anything.
metadata:
  owner: platform-team
  version: "1.2"
---

# Release Notes

Produce a release notes document from merged pull requests between two refs.

## Procedure

1. Determine the range. If the user gave two refs, use them. Otherwise, run:
   `scripts/last-two-tags.sh` and use its output as `FROM` and `TO`.
2. Collect merged PRs in that range:
   `scripts/prs-in-range.sh FROM TO`
   This prints one JSON object per line with `number`, `title`, `labels`, `author`.
3. Group PRs by label using the mapping in `reference/style.md`. A PR with no
   matching label goes under "Other".
4. Rewrite each PR title as a user-facing sentence. Read `reference/style.md`
   for tone and the list of words to avoid.
5. Write the result to `RELEASE_NOTES.md` at the repo root using
   `templates/release-notes.md` as the skeleton.
6. Report the counts per section and any PRs you dropped as internal-only.

## Never

- Never invent a PR that is not in the script output.
- Never include PRs labeled `internal` or `chore` unless the user asks.
- Never create or push a git tag. That is a separate, human-run step.

## Done when

`RELEASE_NOTES.md` exists, every PR in range is either listed or explicitly
reported as dropped, and the user has the per-section counts.
```

### `release-notes/scripts/last-two-tags.sh`

```bash
#!/usr/bin/env bash
# Print the two most recent semver tags, oldest first, as: FROM TO
set -euo pipefail
git tag --sort=-v:refname | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | head -n 2 | tac | xargs
```

### `release-notes/scripts/prs-in-range.sh`

```bash
#!/usr/bin/env bash
# Usage: prs-in-range.sh FROM TO
# Prints one JSON object per merged PR between the two refs.
set -euo pipefail
from="$1"; to="$2"
git log --merges --format='%s' "${from}..${to}" \
  | grep -oE '#[0-9]+' | tr -d '#' | sort -un \
  | while read -r n; do
      gh pr view "$n" --json number,title,labels,author \
        --jq '{number, title, labels: [.labels[].name], author: .author.login}'
    done
```

### `release-notes/reference/style.md`

```markdown
# Release notes style

## Label to section mapping

| Label        | Section       |
|--------------|---------------|
| feature      | New           |
| enhancement  | Improved      |
| bug          | Fixed         |
| security     | Security      |
| deprecation  | Deprecated    |
| (none)       | Other         |

## Tone

- Present tense, second person: "You can now filter by date."
- One sentence per PR. Lead with the user benefit, not the implementation.
- Link the PR number in parentheses at the end: "(#482)".

## Avoid

"refactor", "cleanup", "misc", "various", "some", "fix stuff", internal class or
function names, ticket IDs from the issue tracker.
```

### `release-notes/templates/release-notes.md`

```markdown
# Release {{VERSION}} — {{DATE}}

## New

## Improved

## Fixed

## Security

## Deprecated

## Other
```

---

## 7. Worked example B: a human-only skill with side effects

This skill commits and pushes. It should never fire on its own, so it uses
`disable-model-invocation: true`. Codex and OpenCode ignore that field, so the body
also tells the model to stop and confirm before pushing. That is the portable
safeguard.

### `ship/SKILL.md`

```markdown
---
name: ship
description: >
  Stages, commits, and pushes the current branch with a conventional commit
  message, then opens a pull request. Invoke with /ship. Only for use when the
  user explicitly asks to ship, commit and push, or open a PR.
disable-model-invocation: true
argument-hint: "[optional commit subject]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*)
---

# Ship

Commit the working tree and open a PR.

## Procedure

1. Run `git status --porcelain`. If it is empty, stop and say there is nothing
   to ship.
2. Run `git branch --show-current`. If it is `main` or `master`, stop and ask
   for a branch name. Never commit directly to the default branch.
3. Run `git diff --stat` and read the change. Draft a conventional commit
   subject (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`). If the user
   passed a subject as the argument, use theirs.
4. Show the user the subject and the file list. **Wait for a yes before
   continuing.** This step is mandatory even if the harness would allow you to
   proceed.
5. `git add -A && git commit -m "<subject>"`
6. `git push -u origin <branch>`
7. `gh pr create --fill`
8. Print the PR URL.

## Never

- Never skip step 4.
- Never force-push.
- Never amend a commit that has already been pushed.
```

Key points illustrated:

- The description still has triggers, because the user has to find it in a list.
- The human confirmation is written into the body, not delegated to a frontmatter
  flag, so it holds across harnesses.
- `allowed-tools` only pre-approves read-only git commands. The write commands
  still go through normal permission prompts.

---

## 8. Worked example C: a pure knowledge skill

Not every skill is a procedure. Some exist to inject conventions when a topic comes
up. These are short, have no scripts, and are never invoked by a human.

### `api-error-conventions/SKILL.md`

````markdown
---
name: api-error-conventions
description: >
  House conventions for HTTP error responses in the public API. Use when
  writing or reviewing any handler that returns a 4xx or 5xx, adding a new
  error code, or touching files under api/errors/. Triggers: error response,
  status code, problem details, error code, validation error.
user-invocable: false
---

# API error conventions

All error responses use RFC 9457 Problem Details.

## Shape

```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation failed",
  "status": 422,
  "detail": "field 'email' must be a valid address",
  "instance": "/users/123",
  "errors": [{"field": "email", "reason": "invalid_format"}]
}
```

## Rules

- `type` is a stable URL. Add new ones to `api/errors/registry.go` and nowhere else.
- `title` is fixed per `type`. `detail` is per-occurrence and human-readable.
- Never leak stack traces, SQL, or internal hostnames in `detail`.
- 422 for validation, 409 for state conflicts, 404 only when the resource path
  itself does not exist. Do not use 400 for validation.
- Every new error code needs a test in `api/errors/registry_test.go`.
````

---

## 9. Making one skill work across all three harnesses

The `SKILL.md` format is a shared standard. What differs is where each tool looks
and which frontmatter fields it honors.

### Discovery paths

| Harness | Personal (all projects) | Project (this repo) |
|---|---|---|
| Claude Code | `~/.claude/skills/<name>/` | `.claude/skills/<name>/` |
| Codex | `~/.codex/skills/<name>/` and `~/.agents/skills/<name>/` | `.codex/skills/<name>/` and `.agents/skills/<name>/` |
| OpenCode | `~/.config/opencode/skills/<name>/`, plus reads `~/.claude/skills/` and `~/.agents/skills/` | `.opencode/skills/<name>/`, plus reads `.claude/skills/` and `.agents/skills/` |

### Strategy: one canonical copy, symlinked everywhere

Never maintain three copies. Keep the real folders in one place and link them.

**Personal skills** (live in your dotfiles):

```bash
# Canonical location, under version control
SKILLS="$HOME/dotfiles/agents/skills"

mkdir -p ~/.claude/skills ~/.codex/skills ~/.agents/skills

for skill in "$SKILLS"/*/; do
  name="$(basename "$skill")"
  ln -sfn "$skill" ~/.claude/skills/"$name"
  ln -sfn "$skill" ~/.codex/skills/"$name"
  ln -sfn "$skill" ~/.agents/skills/"$name"
done
```

OpenCode reads `~/.claude/skills` and `~/.agents/skills` natively, so it needs no
extra link.

**Project skills** (committed to the repo):

```bash
# Canonical location in the repo
mkdir -p .agents/skills

# Codex and OpenCode read .agents/skills directly.
# Claude Code wants .claude/skills, so link the whole directory:
mkdir -p .claude
ln -sfn ../.agents/skills .claude/skills

git add .agents .claude
```

Commit the symlink. Git stores symlinks as symlinks on Linux and macOS.

### Frontmatter portability

- Use only `name`, `description`, `license`, `compatibility`, `metadata` for anything
  that must behave identically everywhere.
- Claude-specific fields are harmless elsewhere but ignored. If a safety property
  matters (like "ask before pushing"), write it into the body as an instruction.
  See example B.

---

## 10. Testing a skill

Do these in a **fresh session** each time so no prior context helps.

1. **Trigger test.** Describe a task without naming the skill. Example: "what
   shipped since the last tag?" The harness should pick `release-notes`. If it
   does not, the description is the problem. Add the exact phrase you used to
   the triggers.
2. **Negative test.** Describe an adjacent task that should *not* trigger it.
   Example: "tag the release as v2.3.0". If `release-notes` fires, tighten the
   exclusion.
3. **Body test.** Invoke it directly (`/release-notes`) and watch where it
   stumbles. If it asks for something the body should have told it, move that
   information higher or make it more explicit.
4. **Cold-read test.** Hand `SKILL.md` to a teammate who has never seen the
   codebase. If they cannot follow it, neither can the model.
5. **Claude Code only:** run `/skill-doctor` for a report on description quality
   and loading issues across installed skills.

---

## 11. Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| One giant skill for a whole domain ("backend") | Description becomes vague, body becomes a manual, routing gets worse | Split into narrow skills with sharp triggers |
| Description explains the domain instead of listing triggers | The model never sees a phrase that matches what the user typed | Rewrite per section 4 |
| Tutorial content in the body | Wastes context on things the model already knows | Keep only what is specific to your setup |
| Overlapping descriptions across skills | The model picks inconsistently | Give each skill a distinct trigger set and exclusion |
| Reasoning through deterministic steps | Slow, expensive, error-prone | Ship a script |
| Relying on `disable-model-invocation` for safety | Ignored by Codex and OpenCode | Put the confirmation step in the body |
| Copy-pasting the same skill into three directories | Drift | One canonical copy, symlinked |
| Restating `CLAUDE.md` / `AGENTS.md` | Doubles the context cost of always-loaded rules | Reference it, do not repeat it |

---

## 12. Blank template

Copy this to start a new skill. Delete what you do not need.

```markdown
---
name: <folder-name>
description: >
  <Verb phrase: what it produces or does.>
  Use when asked to "<phrase 1>", "<phrase 2>", "<phrase 3>", or when editing
  <path>. Triggers: <word>, <word>, <word>. Does not <exclusion>.
---

# <Title>

<One sentence on the outcome.>

## Procedure

1. <Step. Name the command or file.>
2. <Step. If a branch exists, say "If X, read `reference/x.md`".>
3. <Step.>

## Never

- <The most common mistake.>
- <The most dangerous mistake.>

## Done when

<Observable end state and what to report back.>
```

---

## 13. Quick-start checklist

- [ ] Folder name is kebab-case and matches `name`
- [ ] Description: verb phrase + 3 literal trigger phrases + 1 exclusion, under 400 chars
- [ ] Body: numbered steps, essential path first, under 500 lines
- [ ] Deterministic steps are scripts in `scripts/`
- [ ] Deep content is in `reference/`, linked from the body with a one-line "when to read"
- [ ] Side-effect skills have a human confirmation step written in the body
- [ ] One canonical copy, symlinked into `~/.claude/skills`, `~/.codex/skills`, `~/.agents/skills`
- [ ] Passed trigger test, negative test, and body test in fresh sessions
