# Wikinotes agent instructions

Wikinotes is a personal DevOps knowledge base: curated docs, reusable
snippets, and private planning notes, all Markdown, searched with `fzf` and
`ripgrep`. `README.md` explains the layout and naming scheme; this file
covers only what an agent must do differently here.

## Layout and what is searchable

- `docs/<topic>/` holds curated reference material and walkthroughs.
- `examples/<topic>/` holds standalone snippets and command references.
- `notes/` holds private, dated planning material: study plans, project
  build plans, tooling ideas. It is deliberately outside the search index.
- `scripts/wiki.sh` (aliased `w`) indexes only `docs/` and `examples/`.
  Do not add `notes/` to it, and do not move a note into `docs/` unless
  asked; the split is intentional.

## Boundaries

- Do not commit or push unless asked. Leave changes in the working tree and
  offer a Conventional Commit message.
- Never write credentials, tokens, or shell history into a note, even as an
  example. Use obvious placeholders such as `<token>`.
- `install.sh` is the only thing that touches `~/.dotfiles-env.sh`. It
  persists `WIKINOTES_DIR` and the `wikinotes` and `w` aliases and is safe
  to re-run. Do not add aliases anywhere else.

## Conventions

- Every file under `docs/` and `examples/` is named `<topic>-<scope>.md`,
  where `<scope>` is one of the tags listed in `README.md` (`overview`,
  `setup`, `snippets`, `cheatsheet`, and so on). Pick an existing tag before
  inventing one.
- Study plans under `notes/study-plan/` are named
  `<Month>_<DD>_<YYYY>_STUDY_PLAN.md`; a new plan is a new file, not an edit
  to the previous one.
- One topic per file. Prefer a new file over a long appendix to an existing
  one, so `fzf` previews stay useful.
- Write the absolute date when a note refers to "today" or "next week".

## Verify a change

```bash
./install.sh          # after touching install.sh; must print both aliases
bash scripts/wiki.sh  # new docs/examples files must appear in the picker
```
