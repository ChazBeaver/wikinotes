
What you’re looking at is not really a conventional source-code repository. It is Codex’s installed “skill library”: local
instructions, scripts, references, and UI metadata that teach a general AI agent how to perform particular jobs reliably.

The most useful mental model is:

> The model provides general intelligence. Skills provide local operating procedures, domain knowledge, guardrails, and
> reusable tools.

These files do not retrain the model or change its neural-network weights. They change what instructions and resources
Codex can load while handling a request.

## How a request flows

Suppose you ask:

> “Why did Nautilus crash?”

Conceptually, Codex does this:

Your request
    ↓
Compare request with available skill descriptions
    ↓
“crash”, “core dump”, “SIGSEGV” match diagnose-crash
    ↓
Load diagnose-crash/SKILL.md
    ↓
Follow its evidence-gathering workflow
    ↓
Only if Omarchy is responsible:
load reporting.md
    ↓
Use system tools such as coredumpctl, journalctl, gdb, and gh

This is called progressive disclosure:

1. Skill metadata is small and available for routing.
2. The complete SKILL.md is loaded only if the skill is relevant.
3. References and scripts are loaded or executed only when needed.

That keeps irrelevant documentation out of the model’s limited context window.

## Anatomy of one skill

A full-featured skill commonly looks like this:

my-skill/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   └── detailed-topic.md
├── scripts/
│   └── reliable-operation.py
├── assets/
│   └── icon.png
└── LICENSE.txt

Only SKILL.md is fundamentally required.

### SKILL.md: the brain of the skill

It has two parts:

---
name: diagnose-crash
description: >
  Diagnose why a program crashed...
---

followed by Markdown instructions.

The frontmatter answers:

- What is this skill called?
- Which user requests should trigger it?

The Markdown body answers:

- What sequence should Codex follow?
- What evidence should it gather?
- What should it avoid?
- When should it read another file?
- Which commands or scripts should it use?

The description is especially important because it acts roughly like a semantic routing rule. It is not merely decorative
documentation.

For example:

description: >
  Triggers: crash, segfault, SIGSEGV, SIGABRT, core dump...

makes it much more likely that crash-related requests activate the skill.

### agents/openai.yaml: presentation and invocation metadata

Example:

interface:
  display_name: "Image Gen"
  short_description: "Generate or edit images for websites, games, and more"
  icon_small: "./assets/imagegen-small.svg"
  icon_large: "./assets/imagegen.png"
  default_prompt: "Use $imagegen to make or edit an image for this project."

This usually controls the Codex interface:

- Human-readable display name
- Description shown in a skill picker
- Icons
- Suggested starting prompt
- Whether implicit invocation is allowed

It is not normally the skill’s main reasoning instructions. Those live in SKILL.md.

The review-agent skill illustrates an important policy setting:

policy:
  allow_implicit_invocation: false

That means Codex should not silently choose that skill merely because a request resembles a review. It generally needs to
be invoked explicitly.

### references/: knowledge loaded on demand

References hold detailed material that would make SKILL.md too large.

For example:

openai-docs/references/
├── model-selection.md
├── model-migration.md
├── prompting-guide.md
└── mcp-diagnostics.md

If you ask about selecting a model, Codex can read model-selection.md without also loading migration and MCP
troubleshooting instructions.

Links such as:

Read [`reporting.md`](reporting.md)

are resolved relative to the containing SKILL.md directory. They are navigational instructions to the agent, not
programming-language imports.

Good references contain:

- API schemas
- Company policies
- Detailed examples
- Troubleshooting procedures
- Specialized variants
- Information that is needed sometimes, but not on every invocation

### scripts/: deterministic operations

Scripts move fragile or repetitive work out of free-form model reasoning.

For example:

imagegen/scripts/image_gen.py
skill-creator/scripts/quick_validate.py
plugin-creator/scripts/validate_plugin.py

A model could generate equivalent code every time, but a bundled script is:

- More consistent
- Easier to test
- Less error-prone
- More token-efficient
- Reusable across conversations

A useful design rule is:

> Put judgment in instructions; put repeatable mechanics in scripts.

### assets/: materials for interfaces or output

Assets may include:

- UI icons
- Templates
- Logos
- Fonts
- Boilerplate projects
- Example documents
- Images that a workflow copies or modifies

The PNG and SVG files in these system skills are primarily skill-interface artwork. They do not improve model reasoning
directly.

### License files

These describe how the bundled skill, scripts, or assets may be redistributed. They do not affect invocation or behavior.

## What each system skill does

Your .system directory contains skills shipped and managed as part of Codex:

 Skill              Purpose
━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 imagegen           Teaches image generation/editing workflows and supplies helper scripts and prompting references
─────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────────
 openai-docs        Routes OpenAI and Codex questions through current official documentation
─────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────────
 plugin-creator     Creates valid Codex plugin packages and marketplace entries
─────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────────
 review-agent       Performs focused code review; implicit invocation is disabled
─────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────────
 skill-creator      Teaches Codex how to design, scaffold, and validate new skills
─────────────────  ─────────────────────────────────────────────────────────────────────────────────────────────────
 skill-installer    Finds and installs skills from supported sources

The directory also contains:

.codex-system-skills.marker

That is an installation-management marker. It helps Codex distinguish bundled system skills from user-installed ones.

You generally should not edit .system directly. A Codex update may replace those files.

## Why imagegen has so many parts

Its structure separates several concerns:

imagegen/
├── SKILL.md
├── agents/openai.yaml
├── references/
│   ├── cli.md
│   ├── codex-network.md
│   ├── image-api.md
│   ├── prompting.md
│   └── sample-prompts.md
├── scripts/
│   ├── image_gen.py
│   └── remove_chroma_key.py
└── assets/

SKILL.md tells Codex when and how to use image generation.

The references cover different execution environments and techniques:

- CLI use
- Network restrictions
- Image API details
- Prompt construction
- Example prompts

The scripts perform reliable operations:

- Generate an image through a known interface
- Remove a chroma-key background consistently

The assets make the skill recognizable in the UI.

This is a good example of separating orchestration, knowledge, mechanics, and presentation.

## Understanding your Omarchy skills

Your two local entries are actually symbolic links:

~/.codex/skills/omarchy
  → /usr/share/omarchy/default/agents/skills/omarchy

~/.codex/skills/diagnose-crash
  → /usr/share/omarchy/default/agents/skills/diagnose-crash

That architecture is intentional.

Omarchy owns the canonical skill files under /usr/share/omarchy/. Codex discovers them through the conventional ~/.codex/
skills/ location.

Benefits:

- Omarchy can update the skill along with the operating system.
- Codex always sees the current packaged version.
- The files are not duplicated.
- Multiple agent systems could link to the same canonical skill.
- Users are discouraged from modifying package-managed files.

The important ownership boundary is:

/usr/share/omarchy/     package-owned; read but do not edit
~/.codex/skills/        Codex discovery location
~/.config/              user-owned configuration

## The Omarchy skill’s files

The Omarchy directory contains:

SKILL.md
capture.md
contributing.md
hooks.md
hyprland.md
plugins.md
theming.md

Its SKILL.md is the router and core safety manual. It says:

- When the skill is mandatory
- Where Omarchy configuration lives
- Which directories must not be edited
- How to discover available commands
- How to validate changes
- Which topic guide to load

Then it delegates:

 File               Loaded when
━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 hyprland.md        Keybindings, monitors, window rules
─────────────────  ────────────────────────────────────────────
 plugins.md         Bar, widgets, shell plugins, idle behavior
─────────────────  ────────────────────────────────────────────
 theming.md         Themes, colors, fonts, backgrounds
─────────────────  ────────────────────────────────────────────
 hooks.md           Event-driven automation
─────────────────  ────────────────────────────────────────────
 capture.md         Screenshots, recording, OCR and sharing
─────────────────  ────────────────────────────────────────────
 contributing.md    Reporting bugs or contributing upstream

The filenames do not activate themselves. SKILL.md explicitly tells the agent when to read them.

## The crash skill you pasted

You pasted the contents of two separate files:

diagnose-crash/
├── SKILL.md
└── reporting.md

SKILL.md handles diagnosis:

1. Inspect the core dump.
2. Check what command was running.
3. Rule out memory exhaustion.
4. correlate timestamps with journals and updates.
5. Inspect all threads.
6. Symbolize the backtrace when possible.
7. Separate proven facts from inference.
8. Leave the system unchanged.

reporting.md is intentionally conditional. It is only loaded after evidence suggests the problem belongs to Omarchy.

That second file adds stronger safeguards:

- Verify that it is genuinely an Omarchy bug.
- Search existing open and closed issues.
- Avoid useless “me too” comments.
- Show the proposed report to the user first.
- Require explicit permission before filing.
- Verify GitHub authentication.
- Disclose that the report was agent-authored.

This structure prevents reporting instructions from consuming context during an ordinary crash diagnosis. It also makes a
consequential external action—filing an issue—subject to additional rules.

## What your screenshot shows

The screenshot is Vim’s netrw directory browser displaying:

/usr/share/omarchy/default/agents/skills/omarchy/

The entries are the Omarchy skill files described above.

The important status indicators are:

[-][RO]

RO means read-only. That is appropriate because /usr/share/omarchy is package-managed.

The message:

97 lines yanked into "+"

means 97 lines were copied into Vim’s + register, which is normally connected to the system clipboard.

It does not mean the skill was installed or invoked; you were simply browsing and copying its files.

## What really makes this setup effective

Not every file contributes equally.

The highest-value pieces are:

1. A precise trigger description
2. A short, evidence-based workflow
3. Clear safety boundaries
4. Exact commands and validation steps
5. Conditional references
6. Tested scripts for fragile operations
7. Correct access to the underlying tools

Icons and presentation metadata improve discoverability, but they do not materially improve the agent’s technical
reasoning.

Also, these skills do not automatically grant capabilities. A skill can tell Codex to run gdb, but gdb must actually be
installed and permitted. It can explain how to query an API, but credentials and network access must exist.

## Reproducing this on another system

For the other system, use this approach:

1. Install the same current Codex release. Let Codex provide and manage .system; do not manually maintain that directory.
2. Copy or install only your non-system skills under:

~/.codex/skills/<skill-name>/SKILL.md

3. If the other machine runs the same Omarchy version, prefer Omarchy’s packaged skill source and recreate the symlinks:

~/.codex/skills/omarchy
  → /usr/share/omarchy/default/agents/skills/omarchy

~/.codex/skills/diagnose-crash
  → /usr/share/omarchy/default/agents/skills/diagnose-crash

4. If the other machine is not running Omarchy, do not blindly install the Omarchy skills. Their commands, paths, and
   safety assumptions would be wrong.

5. Put your own portable skills in a Git repository. On each machine, either copy them into ~/.codex/skills/ or symlink
   them from the repository.

6. Keep machine-specific facts out of portable SKILL.md files. Put them in per-machine configuration or create separate
   platform-specific references.

7. Validate new skills with the skill-creator tooling rather than hand-checking every convention.

A practical portable layout would be:

dotfiles-or-ai-config/
└── codex-skills/
    ├── troubleshoot-my-stack/
    │   ├── SKILL.md
    │   ├── references/
    │   └── scripts/
    └── maintain-my-project/
        ├── SKILL.md
        └── references/

Then link those skill directories into ~/.codex/skills/.

Do not transfer API keys, authentication databases, conversation history, or all of ~/.codex merely to transfer skills.

## The deeper lesson

A capable local agent setup has three distinct layers:

Model
  General reasoning and language ability

Agent harness
  Tools, permissions, context management, approvals and file access

Skills
  Your reusable expertise, workflows, conventions and safeguards

Skills are powerful because they turn knowledge that normally lives in your head into versioned, repeatable operating
procedures. They make the same model more dependable—but they are not a replacement for the model, tools, permissions, or
installed software.

The structure you found is therefore less like an AI model and more like a carefully designed field manual for one.
Official OpenAI material similarly describes skills as reusable saved workflows that Codex can keep available for repeated
work. OpenAI Codex use cases (https://developers.openai.com/codex/use-cases)
