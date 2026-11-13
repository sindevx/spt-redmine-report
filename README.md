# redmine-report (spt-redmine-report)

Turns finished git work into a **Redmine-ready draft report** (story + life-cycle tasks).  
**Never writes to Redmine** — you review files first; push is optional and separate.

## Install (easiest → fallback)

**Full guide:** [docs/INSTALL.md](docs/INSTALL.md)

### 1) `npx skills` — Claude Code + Cursor + Codex

```bash
npx skills add sindevx/spt-redmine-report -g -a claude-code -a cursor -a codex -y
~/.agents/skills/redmine-report/scripts/install.sh --all   # or ~/.claude/skills/... / ~/.cursor/skills/...
```

### 2) Marketplace / plugin

| Tool | Easiest command / UI |
|---|---|
| **Claude Code** | `/plugin marketplace add sindevx/spt-redmine-report` then `/plugin install spt-redmine-report@spt-redmine-report` |
| **Cursor** | Customize → From GitHub → `sindevx/spt-redmine-report` (or Marketplace when listed) |
| **Codex** | `$skill-installer install https://github.com/sindevx/spt-redmine-report` |

### 3) Manual clone

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --all
```

### Then use these `/` commands

| Command | Purpose |
|---|---|
| `/setup-spt-redmine-report` | One-time setup |
| `/spt-redmine-report-prepare` | Evidence from docs / Postman / notes / Redmine (not code-only) |
| `/spt-redmine-report` | Draft the Redmine report |

See [USER_GUIDE.md](USER_GUIDE.md) for flows and evidence sources.

## What it does

1. One-time setup → `local.md` + Setup summary  
2. Per-report questions  
3. Evidence from code (not commit messages alone)  
4. Life-cycle tasks → draft files under `.scratch/`  
5. Checker → owner review → optional companion push  

Human guide: [USER_GUIDE.md](USER_GUIDE.md) · Agent rules: `SKILL.md`

## License

MIT — see `LICENSE`.
