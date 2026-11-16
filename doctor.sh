#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
[[ $# == 0 ]] || { printf '%s\n' 'Usage: ./doctor.sh' >&2; exit 2; }
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$ROOT/lib/registration.sh"
if ! check_registration "$ROOT" "${DOTFILES_REGISTRY_FILE:-$HOME/.dotfiles-env.sh}"; then
  printf '%s\n' 'Registration is missing or stale; run ./install.sh --non-interactive.' >&2
  exit 1
fi
printf '%s\n' 'All checks passed (repository registration only).'
