#!/usr/bin/env bash
set -euo pipefail

# Get the absolute path to the repo root
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Find markdown files and strip prefix to get relative path
FILE=$(find "$ROOT_DIR/docs" "$ROOT_DIR/examples" -type f -name "*.md" 2>/dev/null |
  sed "s|$ROOT_DIR/||" |
  awk -v root="$ROOT_DIR" '{print $0 "|" root "/" $0}' |
  fzf --prompt="wikinotes (lite) > " --with-nth=1 --delimiter="|" --preview 'grep -E "^#+" {2} || cat {2}' --preview-window=right:60%:wrap |
  cut -d'|' -f2)

# If a file was selected, offer to open it
if [[ -n "${FILE:-}" ]]; then
  echo "======== Preview: $FILE ========"
  grep -E '^#|^##|^###' "$FILE" || cat "$FILE"
  echo "================================"
  read -rp "Open in editor? [y/N]: " CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] && ${EDITOR:-nvim} "$FILE"
fi
