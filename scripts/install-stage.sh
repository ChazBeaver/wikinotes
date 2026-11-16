#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
registry="${DOTFILES_REGISTRY_FILE:-$HOME/.dotfiles-env.sh}"
case "${1:-}" in
  preflight)
    [[ "$(id -u)" != 0 ]] || { printf '%s\n' 'Run as the target user, not root.' >&2; exit 4; }
    [[ -w "$(dirname "$registry")" ]] || { printf '%s\n' 'Registry directory is not writable.' >&2; exit 4; }
    for executable in awk mktemp mv; do command -v "$executable" >/dev/null || exit 4; done
    if [[ -e "$registry" && ! -w "$registry" ]]; then printf '%s\n' 'Registry is not writable.' >&2; exit 4; fi
    printf '%s\n' 'Registration prerequisites are ready.' ;;
  install)
    source "$ROOT/install.sh"
    ensure_wikinotes_env "$ROOT" "$registry"
    printf '%s\n' 'Repository registration updated.' ;;
  verify) exec "$ROOT/doctor.sh" ;;
  *) printf '%s\n' 'Expected preflight, install, or verify.' >&2; exit 2 ;;
esac
