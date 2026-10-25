#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fixture_dir="$(mktemp -d)"
trap 'rm -rf -- "$fixture_dir"' EXIT
source "$REPO_DIR/install.sh"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
env_file="$fixture_dir/install home/.dotfiles-env.sh"
original_home="$HOME"
# Include shell metacharacters to verify that sourcing preserves literal paths.
repo_dir="$fixture_dir/Projects/home/a repo & pipe|quote\"dollar\$backtick\`slash\\"
ensure_wikinotes_env "$repo_dir" "$env_file"
[[ -d "$fixture_dir/install home/Projects/home" ]] || fail 'personal repo parent was not created'
[[ "$HOME" == "$original_home" ]] || fail 'registration changed HOME'
bash -n "$env_file"
expected_alias='alias wikinotes="cd \$WIKINOTES_DIR"'
grep -Fxq "$expected_alias" "$env_file" || fail 'navigation alias missing'
registered="$(bash -c 'source "$1"; printf "%s" "$WIKINOTES_DIR"' bash "$env_file")"
[[ "$registered" == "$repo_dir" ]] || fail 'literal checkout path was not preserved'
cp "$env_file" "$fixture_dir/expected"
ensure_wikinotes_env "$repo_dir" "$env_file"
cmp -s "$env_file" "$fixture_dir/expected" || fail 'registration is not idempotent'
# Stale duplicates must not override the repaired export/alias when sourced.
printf '%s\n' 'export FOREIGN_DIR="/keep/me"' 'alias foreign="keep"' \
  'export WIKINOTES_DIR="/stale/one"' 'export WIKINOTES_DIR="/stale/two"' \
  'alias wikinotes="wrong-one"' 'alias wikinotes="wrong-two"' \
  '  export    WIKINOTES_DIR="/stale/indented"' '  alias   wikinotes="wrong-indented"' > "$env_file"
printf '%s\n' 'alias w="stale"' 'alias w="duplicate"' >> "$env_file"
ensure_wikinotes_env "$repo_dir" "$env_file"
[[ "$(grep -c '^export WIKINOTES_DIR=' "$env_file")" == 1 ]] || fail 'duplicate exports remain'
[[ "$(grep -c '^alias wikinotes=' "$env_file")" == 1 ]] || fail 'duplicate aliases remain'
grep -Fxq 'export FOREIGN_DIR="/keep/me"' "$env_file" || fail 'foreign export changed'
grep -Fxq 'alias foreign="keep"' "$env_file" || fail 'foreign alias changed'
grep -Fxq "$expected_alias" "$env_file" || fail 'stale alias was not repaired'
registered="$(bash -c 'source "$1"; printf "%s" "$WIKINOTES_DIR"' bash "$env_file")"
[[ "$registered" == "$repo_dir" ]] || fail 'stale export was not repaired'
[[ "$(grep -c '^alias w=' "$env_file")" == 1 ]] || fail 'duplicate search aliases remain'
grep -Fxq 'alias w="\$WIKINOTES_DIR/scripts/wiki.sh"' "$env_file" || fail 'search alias was not repaired'
printf 'PASS: registration creates the parent, preserves literal paths and foreign entries, repairs duplicates, and is idempotent\n'
