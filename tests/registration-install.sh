#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
export DOTFILES_REGISTRY_FILE="$fixture/registry" XDG_STATE_HOME="$fixture/state"
original_home="$HOME"
mkdir "$fixture/bin"
printf '%s\n' '#!/usr/bin/env bash' 'printf "1000\n"' > "$fixture/bin/id"
chmod +x "$fixture/bin/id"
export PATH="$fixture/bin:$PATH"
"$repo/install.sh" --check
[[ ! -e "$DOTFILES_REGISTRY_FILE" && ! -e "$XDG_STATE_HOME" ]] || fail 'check wrote registry or state'
if "$repo/doctor.sh" > "$fixture/doctor.out" 2>&1; then fail 'missing registration passed doctor'; fi
printf '%s\n' 'export FOREIGN_DIR="/keep/me"' > "$DOTFILES_REGISTRY_FILE"
"$repo/install.sh" --non-interactive > "$fixture/install.out" 2>&1 || { cat "$fixture/install.out"; fail 'installation failed'; }
"$repo/doctor.sh"
grep -Fxq 'export FOREIGN_DIR="/keep/me"' "$DOTFILES_REGISTRY_FILE" || fail 'foreign registration changed'
cp "$DOTFILES_REGISTRY_FILE" "$fixture/expected"
"$repo/install.sh" --non-interactive > "$fixture/rerun.out" 2>&1 || fail 'rerun failed'
cmp -s "$fixture/expected" "$DOTFILES_REGISTRY_FILE" || fail 'rerun changed registration'
# Existing no-argument registration remains supported, with an explicit fixture registry.
"$repo/install.sh" > "$fixture/legacy.out"
cmp -s "$fixture/expected" "$DOTFILES_REGISTRY_FILE" || fail 'legacy entrypoint differs'
"$repo/install.sh" --help > "$fixture/help.out"
status=0
"$repo/install.sh" --unknown > "$fixture/bad.out" 2>&1 || status=$?
[[ "$status" == 2 ]] || fail 'unknown option not rejected'
cat "$fixture/expected" >> "$DOTFILES_REGISTRY_FILE"
if "$repo/doctor.sh" > "$fixture/duplicate.out" 2>&1; then fail 'duplicate registration passed doctor'; fi
"$repo/install.sh" --non-interactive > "$fixture/repair.out" 2>&1 || fail 'duplicate repair failed'
"$repo/doctor.sh"
status=0
DOTFILES_REGISTRY_FILE="$fixture/missing-parent/registry" "$repo/install.sh" --non-interactive > "$fixture/failure.out" 2>&1 || status=$?
[[ "$status" == 4 ]] || fail 'missing prerequisite did not fail'
[[ ! -e "$fixture/missing-parent" ]] || fail 'failed preflight changed registry'
[[ "$HOME" == "$original_home" ]] || fail 'HOME was changed'
printf '%s\n' 'PASS: registration CLI, read-only checks, repeat installation, duplicate detection, and failures'
