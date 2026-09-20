# Codex Work Setup and Skills Guide

## Mental model

Codex effectiveness comes from several separate layers:

| Layer | Purpose | Work setup |
|---|---|---|
| Model provider | Supplies reasoning through LiteLLM | `~/.codex/config.toml` |
| Global instructions | Defines persistent working habits and safety | `~/.codex/AGENTS.md` |
| Skills | Teaches repeatable workflows | `~/.codex/skills/<skill>/SKILL.md` |
| Tools | Perform real actions | `glab` for GitLab |
| Repository context | Supplies code, templates, and local conventions | Repository files and optional `AGENTS.md` |
| Permissions | Controls filesystem, shell, network, and external writes | Codex sandbox plus explicit confirmation |

A skill teaches Codex *how* to perform a workflow. It does not provide authentication or new capabilities. For example, `glab` supplies GitLab access, while a skill teaches Codex how to use `glab` safely and consistently.

This home machine's personal configuration is relatively small: it has no locally configured MCP servers, and its `config.toml` mainly records trusted projects. Much of its effectiveness comes from strong host-provided instructions, built-in tools, focused skills, and cautious tool use rather than a large collection of personal configuration.

Relevant documentation:

- [Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md)
- [Advanced Codex configuration](https://learn.chatgpt.com/docs/config-file/config-advanced)
- [Model Context Protocol](https://learn.chatgpt.com/docs/extend/mcp)
- [Codex plugins](https://learn.chatgpt.com/docs/plugins)

## Base work configuration

### Configure the LiteLLM gateway

Configure the working LiteLLM gateway in the user-level `~/.codex/config.toml`. Provider and authentication settings belong in user configuration, not in a repository.

```toml
model = "<approved-model-alias>"
model_provider = "work_litellm"

[model_providers.work_litellm]
name = "Work LiteLLM Gateway"
base_url = "https://<company-gateway>/<required-api-prefix>"
env_key = "WORK_LITELLM_TOKEN"
wire_api = "responses"
```

The exact URL, model alias, and environment-variable name should match the company's approved gateway configuration. Current Codex custom providers use the Responses API wire format.

Keep the gateway token in the approved environment or credential system. Never put it in `config.toml`, `AGENTS.md`, a skill, a repository, or a transcript.

### Add global working agreements

Create `~/.codex/AGENTS.md` with durable rules that should apply across repositories:

```markdown
# Working agreements

- Never invent owners, dates, requirements, ticket state, or meeting decisions.
- Clearly label unknown or inferred information.
- Never reveal credentials or write them into project files.
- Preview every external write and obtain confirmation before performing it.
- After an external write, read the result back and report its canonical URL.
- Preserve unrelated repository changes.
```

Keep output templates and detailed workflows out of this file. Those belong in focused skills so they are loaded only when relevant.

### Configure GitLab access

Install and authenticate [`glab`](https://docs.gitlab.com/cli/) against the company's self-managed GitLab hostname using the approved credential mechanism.

The skills should call `glab`; they should never read, print, copy, or store the GitLab token themselves. Use [`glab auth status`](https://docs.gitlab.com/cli/auth/status/) to verify the active hostname and authentication before testing writes.

### Choose the initial extension surface

Do not add MCP servers, plugins, hooks, or deprecated custom prompts for the initial workflow. Local transcript files plus `glab` already provide the required capabilities. Add another extension mechanism only when a concrete need appears, such as retrieving transcripts directly from an external service.

## Skills to create

Create three focused user-level skills under `${CODEX_HOME:-$HOME/.codex}/skills`. Each skill should have a concise `SKILL.md`, optional UI metadata in `agents/openai.yaml`, and only the resources it actually needs.

Use the built-in `$skill-creator` workflow to initialize and validate them. Keep procedural instructions in `SKILL.md`, place output templates in `assets/`, and do not add unrelated files such as a README or changelog.

### `write-meeting-notes`

Purpose: convert a pasted or local TXT, Markdown, or VTT meeting transcript into a decision-focused Markdown document.

Inputs:

- Transcript text or local file
- Optional corrected meeting title and date
- Optional participant-name corrections

Default destination:

```text
$HOME/work-notes/meetings/YYYY/YYYY-MM-DD-slug.md
```

Required output:

- Meeting metadata and source reference
- Concise summary
- Decisions
- Action items with owner, due date, and status
- Risks and dependencies
- Open questions
- Parking-lot topics
- Transcript ambiguities or confidence caveats

Behavioral rules:

- Use `TBD` for missing owners or dates.
- Never turn a suggestion or discussion into a decision without transcript evidence.
- Retain useful timestamps or speaker references when they help trace an important claim.
- Preview the proposed filename before writing into the notes repository.
- Use `assets/meeting-note.md` as the canonical Markdown template.

Example invocation:

```text
$write-meeting-notes Convert planning-call.vtt into our standard meeting note.
```

### `draft-gitlab-issue`

Purpose: turn the current Codex conversation, a meeting note, or a transcript into a GitLab issue draft.

Template selection:

1. Inspect `.gitlab/issue_templates/*.md` in the current repository.
2. Use the only applicable template automatically.
3. Ask for a choice when multiple templates are equally plausible.
4. Use `assets/generic-engineering-issue.md` when no repository template exists.

The generic fallback should cover:

- Problem or desired outcome
- Context and evidence
- Proposed behavior
- Acceptance criteria
- Non-goals
- Risks and dependencies
- Implementation notes, clearly labeled as proposals

If the referenced Codex conversation is not in the active context, request an exported conversation or pasted source instead of reconstructing it from memory.

This skill produces Markdown and a structured preview only. It must never call `glab` or post the issue.

Example invocation:

```text
$draft-gitlab-issue Turn our discussion into a ticket for the current project.
```

### `manage-gitlab-issue`

Purpose: create, update, or comment on issues in the self-managed GitLab instance.

Set `allow_implicit_invocation: false` in `agents/openai.yaml`. External writes should require an explicit `$manage-gitlab-issue` invocation.

Tool policy:

- Use [`glab issue create`](https://docs.gitlab.com/cli/issue/create/) for creation.
- Use [`glab issue update`](https://docs.gitlab.com/cli/issue/update/) for changes.
- Use [`glab issue note`](https://docs.gitlab.com/cli/issue/note/) for comments.
- Use [`glab api`](https://docs.gitlab.com/cli/api/) only when a required field is unsupported by the higher-level issue command.
- Infer the hostname and project from the current repository remote. Ask when the target is missing or ambiguous.

Before every write:

1. Read the current issue when one already exists.
2. Show the exact proposed title, description, metadata, or comment.
3. Ask for confirmation.
4. Make no change if confirmation is declined.

After every successful write:

1. Fetch the issue again.
2. Verify that the requested change is present.
3. Return the project, issue IID, title, state, and canonical URL.

Use temporary description files where appropriate to avoid fragile shell escaping. Never place a credential on a command line or in a temporary file.

Example invocation:

```text
$manage-gitlab-issue Create the issue from the draft above.
```

## Validation and learning exercises

### Validate skill structure

Run the skill creator's `quick_validate.py` against every skill directory. Resolve all naming and frontmatter errors before testing behavior.

Test activation with:

- A direct request that should invoke the skill
- An indirect request expressing the same goal
- An incomplete request that should cause a follow-up question
- A similar request that should not invoke the skill

### Test meeting-note fidelity

Use sample transcripts containing:

- Missing owners and due dates
- Transcription mistakes
- Conflicting statements
- Suggestions that were not accepted as decisions
- Long VTT input with timestamps

Confirm that the skill labels uncertainty and never invents missing facts.

### Test issue drafting

Test repositories containing zero, one, and multiple issue templates. Confirm that the skill uses the repository template when possible and does not post anything.

### Test GitLab management

Use a non-production GitLab test project for the initial validation:

- Verify authentication and self-managed hostname detection.
- Decline a confirmation and confirm that no write occurs.
- Create an issue and read it back.
- Update its description or labels and read it back.
- Add a comment and read it back.
- Exercise invalid-project, expired-token, missing-permission, and network-failure behavior.
- Confirm that no token appears in output, generated files, or command arguments.

## Acceptance criteria

- One command converts a transcript into a consistent, decision-focused note.
- One command converts the current conversation or a supplied document into a repository-template-compatible issue draft.
- A separate explicit command posts or updates that draft through `glab`.
- No GitLab mutation occurs without an exact preview and confirmation.
- Successful GitLab writes are verified and return the canonical issue URL.
- The skills trigger reliably without crowding ordinary coding tasks.
- Meeting transcripts are handled according to company data-classification and LiteLLM retention policies.

## Assumptions

- Codex CLI is the primary work interface.
- The existing LiteLLM-backed basic Codex flow works and supports Responses API streaming.
- Work uses a self-managed GitLab instance and permits `glab`.
- Meeting transcripts may be processed through the company LiteLLM gateway under approved data-handling rules.
- User-wide skills live under `${CODEX_HOME:-$HOME/.codex}/skills`; repository-specific skills may remain under repository `.agents/skills`.
- Skills remain focused and progressively disclosed: workflow guidance in `SKILL.md`, reusable templates in `assets/`, and deterministic scripts only when repeated use proves they are needed.
