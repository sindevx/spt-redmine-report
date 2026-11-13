# redmine-report

A Claude Code skill that turns finished git commits, a release diff, or a feature branch into a Redmine-ready report — business-level story/epic description plus technical subtasks, with real dates and hour estimates from evidence (code, tests, owner hours).

**Never writes to Redmine.** Draft files only. Push is a separate step when a companion skill and Mode `mcp` are configured.

**Human walkthrough:** [USER_GUIDE.md](USER_GUIDE.md) (install, one-time setup, everyday use, troubleshooting).

## Install

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.claude/skills/redmine-report
~/.claude/skills/redmine-report/scripts/install.sh
```

`install.sh` copies the slash command into `~/.claude/commands/` (and `~/.cursor/commands/` when present) and creates `local.md` from the example if missing.

Works with runtimes that read `~/.claude/skills/` (or `~/.agents/skills/`).

## Setup (once)

In chat:

```text
/setup-spt-redmine-report
```

Reset later:

```text
/setup-spt-redmine-report reset
```

| Mode | Behaviour |
|---|---|
| `report-only` | Default for new installs. Draft files only. No Redmine calls. |
| `mcp` | Owner picks a Redmine MCP name from namespaces on this machine. Skill probes and stores trackers, statuses, priorities, activities. |
| `manual` | No MCP. Owner pastes tracker/status names once into `local.md`. |

`local.md` is git-ignored. It holds everything instance-specific.

## What it does

1. One-time setup → `local.md` + setup summary  
2. Per-report questions (scope, parent, hours, shape)  
3. Read code and evidence  
4. Life-cycle tasks: Analysis → Design → Implement → Test → UAT → Production  
5. Write `.scratch/<feature>/redmine-report.md` + `redmine-report-notes.md`  
6. Run `scripts/check_report.py` until `RESULT: PASS`  
7. Owner review; optional companion push when Mode is `mcp`

See `SKILL.md`. Detail: `references/full-rules.md`.

## Why

Redmine has no built-in Epic/Story/Task levels like Jira — `tracker` is a label; hierarchy is `parent_issue_id`. Tracker names differ per instance. This skill records the real map during setup instead of assuming one.

## Develop

```bash
./tools/check.sh
```

Fails if shipped files contain personal machine names, org names, or other secrets-shaped strings that belong only in `local.md`.

## License

MIT — see `LICENSE`.
