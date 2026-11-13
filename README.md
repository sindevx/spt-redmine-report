# redmine-report (spt-redmine-report)

Turns finished git work into a **Redmine-ready draft report** (story + life-cycle tasks).  
**Never writes to Redmine** — you review files first; push is optional and separate.

## Install (Claude Code · Cursor · Codex)

**Full guide (pick your tool):** [docs/INSTALL.md](docs/INSTALL.md)

### Fastest — all tools on this machine

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --all
```

Then in chat:

```text
/setup-spt-redmine-report
```

| Tool | Personal skills path | After install |
|---|---|---|
| **Claude Code** | `~/.claude/skills/redmine-report` | `/setup-spt-redmine-report` · `/skills` |
| **Cursor** | `~/.cursor/skills/` or `~/.agents/skills/` | `/setup-spt-redmine-report` · Customize → Skills |
| **Codex** | `~/.agents/skills/redmine-report` | `$redmine-report` or ask for setup |

One tool only? See [docs/INSTALL.md](docs/INSTALL.md) for `--claude`, `--cursor`, `--codex`, and project-scoped installs.

## What it does

1. **One-time setup** → `local.md` + Setup summary (Mode, MCP, trackers…)  
2. Per-report questions  
3. Read code/evidence  
4. Life-cycle tasks: Analysis → Design → Implement → Test → UAT → Production  
5. Write `.scratch/<feature>/redmine-report.md` + `redmine-report-notes.md`  
6. `scripts/check_report.py` until `RESULT: PASS`  
7. Owner review; optional companion push when Mode is `mcp`

Human walkthrough: [USER_GUIDE.md](USER_GUIDE.md) · Agent rules: `SKILL.md`

## Why

Redmine has no built-in Epic/Story/Task levels like Jira — hierarchy is `parent_issue_id`. Tracker names differ per instance. Setup records **your** map instead of baking one in.

## Develop

```bash
./tools/check.sh
```

## License

MIT — see `LICENSE`.
