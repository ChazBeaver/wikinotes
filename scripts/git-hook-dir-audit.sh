#!/usr/bin/env zsh
# hook-audit.zsh — inspect repos before enabling a global core.hooksPath. Read-only.
# Usage: ./hook-audit.zsh ~/Projects/home ~/Projects/work ~/wherever/your/dotfiles
emulate -L zsh

roots=("$@")
(( ${#roots} )) || { echo "Usage: $0 <dir-of-repos> [more-dirs...]"; exit 2; }

echo "Current GLOBAL core.hooksPath: ${$(git config --global --get core.hooksPath):-<not set>}\n"
found=0

for root in $roots; do
  root=${root/#\~/$HOME}
  [[ -d $root ]] || { echo "⚠  skip (not a dir): $root"; continue; }

  for gitpath in $root/**/.git(N); do
    repo=${gitpath:h}
    local_hp=$(git -C "$repo" config --local --get core.hooksPath 2>/dev/null)

    active=()
    hd="$repo/.git/hooks"
    if [[ -d $hd ]]; then
      for h in $hd/*(N.); do
        [[ $h == *.sample ]] && continue
        [[ -x $h ]] && active+=("${h:t}")
      done
    fi

    if [[ -n $local_hp || ${#active} -gt 0 ]]; then
      found=1
      echo "── $repo"
      [[ -n $local_hp ]] && echo "    • local hooksPath = $local_hp  → your global guard will NOT run here"
      (( ${#active} )) && echo "    • active hooks: ${active[*]}  → these STOP once you set a global hooksPath"
    fi
  done
done

echo ""
(( found )) \
  && echo "Review the repos above before running: git config --global core.hooksPath <dir>" \
  || echo "✓ No custom hooks or local hooksPath found — safe to enable a global hooksPath."
