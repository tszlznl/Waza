#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Required frontmatter: name, description, version must all be present
for f in skills/*/SKILL.md; do
  for field in name description; do
    if ! head -5 "$f" | grep -q "^${field}:"; then
      echo "MISSING ${field}: in $f" >&2
      exit 1
    fi
  done
  if ! grep -q "^  version:" "$f"; then
    echo "MISSING version: in $f" >&2
    exit 1
  fi
  echo "ok: $f"
done

# Version consistency: derived from filesystem, not hardcoded list
# Catches new skills added to skills/ but missing from marketplace.json
for f in skills/*/SKILL.md; do
  skill=$(basename "$(dirname "$f")")
  skill_ver=$(grep -m1 "version:" "$f" | tr -d '"' | awk '{print $2}')
  market_ver=$(python3 -c "
import json, sys
d = json.load(open('marketplace.json'))
entries = [p['version'] for p in d['plugins'] if p['name'] == sys.argv[1]]
print(entries[0] if entries else 'MISSING')
" "$skill")
  if [ "$market_ver" = "MISSING" ]; then
    echo "NOT IN MARKETPLACE: $skill" >&2
    exit 1
  fi
  if [ "$skill_ver" = "$market_ver" ]; then
    echo "ok: $skill $skill_ver"
  else
    echo "MISMATCH: $skill SKILL=$skill_ver MARKET=$market_ver" >&2
    exit 1
  fi
done

# Reference files exist for skills that use them
test -f skills/design/references/design-reference.md && \
test -f skills/read/references/read-methods.md && \
test -f skills/write/references/write-zh.md && \
test -f skills/write/references/write-en.md && \
test -f skills/health/agents/inspector-context.md && \
test -f skills/health/agents/inspector-control.md && \
test -f skills/check/agents/reviewer-security.md && \
test -f skills/check/agents/reviewer-architecture.md && \
test -f skills/check/references/persona-catalog.md && echo "references: ok"

# marketplace.json is valid JSON
python3 -c "import json; json.load(open('marketplace.json'))" && echo "marketplace.json: ok"
