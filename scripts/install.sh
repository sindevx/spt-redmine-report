#!/usr/bin/env bash
# Install slash command + ensure local.md exists.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMD_SRC="$ROOT/commands/setup-spt-redmine-report.md"
CMD_NAME="setup-spt-redmine-report.md"

if [[ ! -f "$CMD_SRC" ]]; then
  echo "FAIL: missing $CMD_SRC"
  exit 1
fi

install_cmd() {
  local dir="$1"
  mkdir -p "$dir"
  cp "$CMD_SRC" "$dir/$CMD_NAME"
  echo "Installed /$CMD_NAME → $dir/$CMD_NAME"
}

# Claude Code user commands
install_cmd "${HOME}/.claude/commands"

# Cursor user commands (when the folder is used)
if [[ -d "${HOME}/.cursor" ]]; then
  install_cmd "${HOME}/.cursor/commands"
fi

if [[ ! -f "$ROOT/local.md" ]]; then
  cp "$ROOT/local.example.md" "$ROOT/local.md"
  echo "Created $ROOT/local.md from local.example.md"
else
  echo "Kept existing $ROOT/local.md"
fi

echo
echo "Next: in chat, run /setup-spt-redmine-report"
echo "Reset later: /setup-spt-redmine-report reset"
