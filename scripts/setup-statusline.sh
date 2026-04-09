#!/bin/bash
# Install Waza statusline into Claude Code
set -e

DEST="$HOME/.claude/statusline.sh"
RAW="https://raw.githubusercontent.com/tw93/Waza/main/scripts/statusline.sh"

# Ensure jq is available
if ! command -v jq &>/dev/null; then
  if command -v brew &>/dev/null; then
    echo "Installing jq via Homebrew..."
    brew install jq
  else
    echo "Error: jq is required but not installed. Install it first: https://jqlang.github.io/jq/" >&2
    exit 1
  fi
fi

# Download statusline script
curl -sL "$RAW" -o "$DEST"
chmod +x "$DEST"

# Check for existing statusLine (skip if already Waza)
EXISTING=$(python3 -c "
import json, os
path = os.path.expanduser('~/.claude/settings.json')
if os.path.exists(path):
    try:
        d = json.load(open(path))
        sl = d.get('statusLine', {})
        cmd = sl.get('command', '')
        if cmd and cmd != 'bash ~/.claude/statusline.sh':
            print(cmd)
    except: pass
" 2>/dev/null)

if [ -n "$EXISTING" ]; then
  echo "Another statusline is already configured:"
  echo "  $EXISTING"
  printf "Replace it with Waza statusline? [Y/n] "
  read -r ans
  if [ "$ans" = "n" ] || [ "$ans" = "N" ]; then
    echo "Skipped. Existing statusline kept."
    exit 0
  fi
fi

# Write statusLine into ~/.claude/settings.json
python3 - <<'PYEOF'
import json, os

path = os.path.expanduser("~/.claude/settings.json")
d = {}
if os.path.exists(path):
    with open(path) as f:
        try:
            d = json.load(f)
        except Exception:
            d = {}

d["statusLine"] = {"type": "command", "command": "bash ~/.claude/statusline.sh"}

with open(path, "w") as f:
    json.dump(d, f, indent=2)
    f.write("\n")
PYEOF

echo "Waza statusline installed. Restart Claude Code to activate."
echo "Tip: if you see a 513 error after switching Claude accounts, remove the statusLine entry from ~/.claude/settings.json, restart Claude Code, then re-run this script."
