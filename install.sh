#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

ensure_wikinotes_env() {
  local repo_dir="$1"
  # An explicit registry path lets fixtures avoid the real home directory.
  local env_file="${2:-$HOME/.dotfiles-env.sh}"
  local escaped_repo_dir temporary
  escaped_repo_dir="${repo_dir//\\/\\\\}"
  escaped_repo_dir="${escaped_repo_dir//\"/\\\"}"
  escaped_repo_dir="${escaped_repo_dir//\$/\\\$}"
  escaped_repo_dir="${escaped_repo_dir//\`/\\\`}"
  local expected_export="export WIKINOTES_DIR=\"$escaped_repo_dir\""
  local expected_alias='alias wikinotes="cd \$WIKINOTES_DIR"'
  local expected_w_alias='alias w="\$WIKINOTES_DIR/scripts/wiki.sh"'
  mkdir -p -- "$(dirname -- "$env_file")/Projects/home" || return 1
  [[ -e "$env_file" ]] || touch -- "$env_file" || return 1
  temporary="$(mktemp "${env_file}.XXXXXX")" || return 1
  # ENVIRON preserves literal backslashes; awk -v would interpret them.
  if ! DOTFILES_REGISTER_EXPORT="$expected_export" \
       DOTFILES_REGISTER_ALIAS="$expected_alias" DOTFILES_REGISTER_W_ALIAS="$expected_w_alias" awk '
    BEGIN {
      desired_export = ENVIRON["DOTFILES_REGISTER_EXPORT"]
      desired_alias = ENVIRON["DOTFILES_REGISTER_ALIAS"]
      desired_w_alias = ENVIRON["DOTFILES_REGISTER_W_ALIAS"]
    }
    $0 ~ /^[[:space:]]*export[[:space:]]+WIKINOTES_DIR=/ {
      if (!seen_export++) print desired_export
      next
    }
    $0 ~ /^[[:space:]]*alias[[:space:]]+wikinotes=/ {
      if (!seen_alias++) print desired_alias
      next
    }
    $0 ~ /^[[:space:]]*alias[[:space:]]+w=/ {
      if (!seen_w_alias++) print desired_w_alias
      next
    }
    { print }
    END {
      if (!seen_export) print desired_export
      if (!seen_alias) print desired_alias
      if (!seen_w_alias) print desired_w_alias
    }
  ' "$env_file" > "$temporary"; then
    rm -f -- "$temporary"
    return 1
  fi
  if ! mv -- "$temporary" "$env_file"; then
    rm -f -- "$temporary"
    return 1
  fi
  export WIKINOTES_DIR="$repo_dir"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
cat <<'BANNER'

 _    _ _____ _   _______  _   _ _____ _____ _____ _____ 
| |  | |_   _| | / /_   _|| \ | |  _  |_   _|  ___/  ___|
| |  | | | | | |/ /  | |  |  \| | | | | | | | |__ \ `--. 
| |/\| | | | |    \  | |  | . ` | | | | | | |  __| `--. \
\  /\  /_| |_| |\  \_| |  | |\  \ \_/ / | | | |___/\__/ /
 \/  \/ \___/\_| \_/\___/ \_| \_/\___/  \_/ \____/\____/ 
                                                             
                   Installing WikiNotes

BANNER
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  ensure_wikinotes_env "$SCRIPT_DIR"
  printf '%s\n' "✅ WIKINOTES_DIR: $WIKINOTES_DIR"
  printf '%s\n' "✅ Aliases 'wikinotes' and 'w' persisted in $HOME/.dotfiles-env.sh"
  printf '%s\n' 'Open a new shell or source ~/.dotfiles-env.sh.'
fi
