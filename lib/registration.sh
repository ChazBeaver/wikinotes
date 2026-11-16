#!/usr/bin/env bash
# Read-only registration checks; install.sh owns registration writes.
check_registration() {
  local repo_dir="$1" file="$2" escaped
  [[ -r "$file" ]] || return 1
  escaped="${repo_dir//\\/\\\\}"
  escaped="${escaped//\"/\\\"}"
  escaped="${escaped//\$/\\\$}"
  escaped="${escaped//\`/\\\`}"
  [[ "$(awk '/^[[:space:]]*export[[:space:]]+WIKINOTES_DIR=/ {n++} END {print n+0}' "$file")" == 1 ]] || return 1
  [[ "$(awk '/^[[:space:]]*alias[[:space:]]+wikinotes=/ {n++} END {print n+0}' "$file")" == 1 ]] || return 1
  grep -Fxq "export WIKINOTES_DIR=\"$escaped\"" "$file" || return 1
  grep -Fxq 'alias wikinotes="cd \$WIKINOTES_DIR"' "$file" || return 1
  [[ "$(awk '/^[[:space:]]*alias[[:space:]]+w=/ {n++} END {print n+0}' "$file")" == 1 ]] || return 1
  grep -Fxq 'alias w="\$WIKINOTES_DIR/scripts/wiki.sh"' "$file" || return 1
  return 0
}
