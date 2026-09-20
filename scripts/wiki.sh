#!/usr/bin/env bash
set -euo pipefail

# Resolve absolute path to repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Find all markdown files and display relative paths from repo root
FILE=$(find "$ROOT_DIR/docs" "$ROOT_DIR/examples" -type f -name "*.md" 2>/dev/null |
  sed "s|$ROOT_DIR/||" |
  awk -v root="$ROOT_DIR" '{print $0 "|" root "/" $0}' |
  fzf --prompt="wikinotes > " --with-nth=1 --delimiter="|" --preview 'cat {2}' --preview-window=right:60%:wrap |
  cut -d'|' -f2)

# Open selected file if chosen
if [[ -n "${FILE:-}" ]]; then
  ${EDITOR:-nvim} "$FILE"
fi
