#!/usr/bin/env bash
# Persist WIKINOTES_DIR and its aliases in ~/.dotfiles-env.sh.
# Safe to re-run: existing lines are updated in place, missing ones appended.
set -euo pipefail
IFS=$'\n\t'

# Get the absolute path of the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target env file for storing aliases and env vars
ENV_FILE="$HOME/.dotfiles-env.sh"

# Banner
cat <<'BANNER'

 _    _ _____ _   _______  _   _ _____ _____ _____ _____ 
| |  | |_   _| | / /_   _|| \ | |  _  |_   _|  ___/  ___|
| |  | | | | | |/ /  | |  |  \| | | | | | | | |__ \ `--. 
| |/\| | | | |    \  | |  | . ` | | | | | | |  __| `--. \
\  /\  /_| |_| |\  \_| |  | |\  \ \_/ / | | | |___/\__/ /
 \/  \/ \___/\_| \_/\___/ \_| \_/\___/  \_/ \____/\____/ 
                                                             
                   Installing WikiNotes

BANNER

ensure_wikinotes_env() {
  local repo_dir="$1"
  local env_file="$2"
  local escaped_repo_dir
  local expected_export="export WIKINOTES_DIR=\"$repo_dir\""
  local expected_alias='alias wikinotes="cd \$WIKINOTES_DIR"'
  local expected_w_alias='alias w="\$WIKINOTES_DIR/scripts/wiki.sh"'

  mkdir -p "$(dirname "$env_file")"
  [[ -e "$env_file" ]] || touch "$env_file"

  escaped_repo_dir="${repo_dir//\\/\\\\}"
  escaped_repo_dir="${escaped_repo_dir//|/\\|}"
  escaped_repo_dir="${escaped_repo_dir//&/\\&}"

  if grep -Fqx "$expected_export" "$env_file"; then
    :
  elif grep -q '^export WIKINOTES_DIR=' "$env_file"; then
    sed -i "s|^export WIKINOTES_DIR=.*|export WIKINOTES_DIR=\"$escaped_repo_dir\"|" "$env_file"
  else
    printf 'export WIKINOTES_DIR="%s"\n' "$repo_dir" >> "$env_file"
  fi

  if grep -Fqx "$expected_alias" "$env_file"; then
    :
  elif grep -q '^alias wikinotes=' "$env_file"; then
    sed -i 's|^alias wikinotes=.*|alias wikinotes="cd \\$WIKINOTES_DIR"|' "$env_file"
  else
    printf '%s\n' "$expected_alias" >> "$env_file"
  fi

  if grep -Fqx "$expected_w_alias" "$env_file"; then
    :
  elif grep -q '^alias w=' "$env_file"; then
    sed -i 's|^alias w=.*|alias w="\\$WIKINOTES_DIR/scripts/wiki.sh"|' "$env_file"
  else
    printf '%s\n' "$expected_w_alias" >> "$env_file"
  fi

  export WIKINOTES_DIR="$repo_dir"
}

ensure_wikinotes_env "$SCRIPT_DIR" "$ENV_FILE"
echo "✅ WIKINOTES_DIR: $WIKINOTES_DIR"
echo "✅ Aliases 'wikinotes' and 'w' persisted in $ENV_FILE"
echo "   Open a new shell (or 'source $ENV_FILE') to use them."
