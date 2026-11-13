#!/usr/bin/env bash
# Install spt-redmine-report for Claude Code, Cursor, and/or Codex.
#
# Usage:
#   ./scripts/install.sh --all
#   ./scripts/install.sh --claude [--cursor] [--codex]
#   ./scripts/install.sh --claude --project   # also write repo .claude/commands/
#
# Run from inside the skill folder, or after cloning to a skills path.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMD_DIR="$ROOT/commands"
SKILL_NAME="redmine-report"

DO_CLAUDE=0
DO_CURSOR=0
DO_CODEX=0
DO_PROJECT=0

usage() {
  cat <<'EOF'
Install spt-redmine-report for Claude Code, Cursor, and/or Codex.

Usage:
  ./scripts/install.sh --all
  ./scripts/install.sh --claude [--cursor] [--codex]
  ./scripts/install.sh --claude --project

See docs/INSTALL.md for per-tool paths and checks.
EOF
  exit "${1:-0}"
}

if [[ $# -eq 0 ]]; then
  # Sensible default: whatever dirs already exist on this machine
  DO_CLAUDE=1
  DO_CURSOR=1
  DO_CODEX=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) DO_CLAUDE=1; DO_CURSOR=1; DO_CODEX=1; shift ;;
    --claude) DO_CLAUDE=1; shift ;;
    --cursor) DO_CURSOR=1; shift ;;
    --codex) DO_CODEX=1; shift ;;
    --project) DO_PROJECT=1; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1"; usage 1 ;;
  esac
done

if [[ ! -f "$ROOT/SKILL.md" ]]; then
  echo "FAIL: SKILL.md not found at $ROOT"
  exit 1
fi
if [[ ! -d "$CMD_DIR" ]] || ! compgen -G "$CMD_DIR"/*.md >/dev/null; then
  echo "FAIL: no command files in $CMD_DIR"
  exit 1
fi

link_or_hint() {
  local target="$1"
  local link="$2"
  mkdir -p "$(dirname "$link")"
  if [[ -e "$link" || -L "$link" ]]; then
    if [[ "$(cd "$link" 2>/dev/null && pwd -P)" == "$(cd "$ROOT" && pwd -P)" ]]; then
      echo "OK skill already at $link"
      return
    fi
    echo "SKIP $link (exists and is not this clone). Remove it to relink."
    return
  fi
  ln -sfn "$ROOT" "$link"
  echo "Linked $link → $ROOT"
}

install_cmds() {
  local dir="$1"
  mkdir -p "$dir"
  local f base
  for f in "$CMD_DIR"/*.md; do
    base="$(basename "$f")"
    cp "$f" "$dir/$base"
    echo "Installed /${base%.md} → $dir/$base"
  done
}

echo "Skill root: $ROOT"
echo

# Prefer ~/.agents/skills as the shared home when installing --all from a random clone path
AGENTS_HOME="${HOME}/.agents/skills/${SKILL_NAME}"
CLAUDE_HOME="${HOME}/.claude/skills/${SKILL_NAME}"
CURSOR_HOME="${HOME}/.cursor/skills/${SKILL_NAME}"

if [[ "$DO_CODEX" -eq 1 ]]; then
  mkdir -p "${HOME}/.agents/skills"
  if [[ "$(cd "$ROOT" && pwd -P)" != "$(mkdir -p "$AGENTS_HOME" 2>/dev/null; cd "$AGENTS_HOME" 2>/dev/null && pwd -P)" ]]; then
    if [[ ! -e "$AGENTS_HOME" ]]; then
      ln -sfn "$ROOT" "$AGENTS_HOME"
      echo "Linked $AGENTS_HOME → $ROOT  (Codex)"
    else
      echo "OK Codex path present: $AGENTS_HOME"
    fi
  else
    echo "OK Codex path is this clone: $ROOT"
  fi
fi

if [[ "$DO_CLAUDE" -eq 1 ]]; then
  mkdir -p "${HOME}/.claude/skills"
  if [[ "$(cd "$ROOT" && pwd -P)" == "$(cd "$CLAUDE_HOME" 2>/dev/null && pwd -P)" ]]; then
    echo "OK Claude path is this clone: $ROOT"
  else
    link_or_hint "$ROOT" "$CLAUDE_HOME"
  fi
  install_cmds "${HOME}/.claude/commands"
  if [[ "$DO_PROJECT" -eq 1 ]]; then
    # Install command into current git repo if we are inside one
    if REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
      install_cmds "${REPO_ROOT}/.claude/commands"
      echo "Project Claude commands: ${REPO_ROOT}/.claude/commands"
    else
      echo "WARN --project: not inside a git repo; skipped .claude/commands"
    fi
  fi
fi

if [[ "$DO_CURSOR" -eq 1 ]]; then
  if [[ -d "${HOME}/.cursor" ]] || [[ "$DO_CURSOR" -eq 1 ]]; then
    mkdir -p "${HOME}/.cursor/skills" "${HOME}/.cursor/commands"
    if [[ "$(cd "$ROOT" && pwd -P)" == "$(cd "$CURSOR_HOME" 2>/dev/null && pwd -P)" ]]; then
      echo "OK Cursor path is this clone: $ROOT"
    else
      link_or_hint "$ROOT" "$CURSOR_HOME"
    fi
    install_cmds "${HOME}/.cursor/commands"
    if [[ "$DO_PROJECT" -eq 1 ]]; then
      if REPO_ROOT="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"; then
        install_cmds "${REPO_ROOT}/.cursor/commands"
        echo "Project Cursor commands: ${REPO_ROOT}/.cursor/commands"
      fi
    fi
  fi
fi

if [[ ! -f "$ROOT/local.md" ]]; then
  cp "$ROOT/local.example.md" "$ROOT/local.md"
  echo "Created $ROOT/local.md"
else
  echo "Kept existing $ROOT/local.md"
fi

echo
echo "Done."
echo "Commands:"
echo "  /setup-spt-redmine-report           one-time setup"
echo "  /spt-redmine-report-prepare         evidence from docs/Postman/notes/…"
echo "  /spt-redmine-report                 draft the Redmine report"
echo "  /setup-spt-redmine-report reset     reset setup"
echo "Guide: USER_GUIDE.md · docs/INSTALL.md"
