---
description: One-time setup for spt-redmine-report (Mode, MCP, instance map → local.md)
argument-hint: "[reset]"
---

# /setup-spt-redmine-report

User invoked: `/setup-spt-redmine-report $ARGUMENTS`

Run **only** the one-time setup for the `redmine-report` skill. Do not draft a report in this command.

Skill home (prefer the first path that exists):

- `~/.claude/skills/redmine-report`
- `~/.agents/skills/redmine-report`

Config file: `<skill-home>/local.md` (git-ignored). Template: `<skill-home>/local.example.md`.

## Reset

If `$ARGUMENTS` contains `reset`, or `local.md` already has `Setup completed` and the user asked to reset: clear `Setup completed` and `Setup summary`, then run setup again from scratch.

## Steps

1. If `local.md` is missing, copy `local.example.md` → `local.md`.
2. Read `USER_GUIDE.md` (Setup section) and the Step 0 block in `SKILL.md` — follow those questions; do not invent answers.
3. Ask once (one message):
   - Mode: `mcp` | `report-only` | `manual` (default for new installs: `report-only`)
   - If `mcp`: list Redmine-related MCP namespaces on this machine; owner picks one name
   - Default project (id or name), or "ask each report"
   - Test command (`none` or real command)
   - Custom fields needed (`none` or name each)
   - Optional sibling issue id for title/hours style
4. Probe and write into `local.md`:
   - `mcp`: read-only trackers, statuses, priorities, activities, versions when possible
   - `manual`: owner pastes tracker/status names (and ids if known)
   - `report-only`: save Mode and preferences only; skip live Redmine
5. Set `Setup completed` to today's date. Write a **Setup summary** (5–10 plain lines): mode, MCP name, project, trackers, statuses, custom fields, test command.
6. Show the Setup summary in chat. Stop. Confirm setup is done and that the next step is a normal report request (not this command again).

## Rules

- Never invent an MCP server name.
- Never POST/PUT to Redmine from this command.
- Never bake instance ids into shipped skill files — only `local.md`.
- If a companion push skill exists, keep the MCP server name identical there; set `Companion MCP aligned` when checked.
