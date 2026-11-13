#!/usr/bin/env bash
# Fail if shipped skill files look personal or org-specific.
# local.md is gitignored and is the only place for machine-specific values.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
allow='^(tools/check\.sh$|local\.md$|local\.example\.md$)'

scan() {
  local pattern="$1"
  local label="$2"
  while IFS= read -r f; do
    rel="${f#./}"
    if echo "$rel" | grep -Eq "$allow"; then
      continue
    fi
    if grep -nEi "$pattern" "$f" >/dev/null 2>&1; then
      echo "FAIL [$label]: $rel"
      grep -nEi "$pattern" "$f" || true
      fail=1
    fi
  done < <(find . -type f \( -name '*.md' -o -name '*.py' -o -name '*.sh' \) ! -path './.git/*')
}

# Org / personal / machine defaults that must not ship
scan 'indochina' 'org name'
scan 'm-smart|msmart' 'internal product name'
scan '\bCGS\b' 'vendor codename'
scan 'CoreBankService' 'internal label'
scan 'redmine_dev' 'personal MCP default'
scan 'mcp__redmin' 'personal MCP tool prefix'
scan 'sindevx|sinkerd' 'personal identity'
scan 'Posting Queue' 'internal project name'
scan 'profiles/ib|ib-defaults|Profile: ib' 'personal profile path'
scan '\bMPAY\b|\bTXN\b' 'internal system codename'
scan 'sinkerd|phoutthavong' 'personal name'
scan 'MicroserviceRoutes|SUBURL' 'internal route vocabulary'

if [[ ! -f local.example.md ]]; then
  echo "FAIL: missing local.example.md"
  fail=1
fi
if [[ -d profiles ]]; then
  echo "FAIL: profiles/ must not ship (use local.md only)"
  fail=1
fi
if [[ -d archive ]]; then
  echo "FAIL: archive/ must not ship"
  fail=1
fi
if [[ -f references/ib-defaults.md ]]; then
  echo "FAIL: references/ib-defaults.md must not ship"
  fail=1
fi
if ! grep -q 'local.md' .gitignore 2>/dev/null; then
  echo "FAIL: local.md must be gitignored"
  fail=1
fi
if grep -q 'Setup completed' local.example.md && grep -q 'Setup summary' local.example.md; then
  :
else
  echo "FAIL: local.example.md must include Setup completed and Setup summary"
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  echo "RESULT: FAIL"
  exit 1
fi
echo "RESULT: PASS"
