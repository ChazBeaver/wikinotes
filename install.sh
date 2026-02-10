#!/usr/bin/env bash
set -euo pipefail

# Get the absolute path of the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target env file for storing aliases and env vars
ENV_FILE="$HOME/.dotfiles-env.sh"
mkdir -p "$(dirname "$ENV_FILE")"

# Banner
cat <<'EOF'

 _    _ _____ _   _______  _   _ _____ _____ _____ _____ 
| |  | |_   _| | / /_   _|| \ | |  _  |_   _|  ___/  ___|
| |  | | | | | |/ /  | |  |  \| | | | | | | | |__ \ `--. 
| |/\| | | | |    \  | |  | . ` | | | | | | |  __| `--. \
\  /\  /_| |_| |\  \_| |  | |\  \ \_/ / | | | |___/\__/ /
 \/  \/ \___/\_| \_/\___/ \_| \_/\___/  \_/ \____/\____/ 
                                                             
                   Installing WikiNotes

EOF

# Add or update WIKINOTES_DIR and its aliases
if ! grep -q "WIKINOTES_DIR=" "$ENV_FILE" 2>/dev/null; then
  echo "export WIKINOTES_DIR=\"$SCRIPT_DIR\"" >> "$ENV_FILE"
  echo "alias wikinotes=\"cd \$WIKINOTES_DIR\"" >> "$ENV_FILE"
  echo "alias w=\"\$WIKINOTES_DIR/scripts/wiki.sh\"" >> "$ENV_FILE"
  echo "✅ Added WIKINOTES_DIR, wikinotes, and w aliases to $ENV_FILE"
else
  echo "⚠️ WIKINOTES_DIR already exists in $ENV_FILE"
fi

# Source it immediately if in interactive shell
if [[ "$-" == *i* ]]; then
  source "$ENV_FILE"
fi
