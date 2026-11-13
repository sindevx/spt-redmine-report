# Install — easiest first

Repo: https://github.com/sindevx/spt-redmine-report  
After any install method:

1. Run `scripts/install.sh` (or `--all`) so **all** slash commands are installed  
2. One-time setup: `/setup-spt-redmine-report`  
3. Optional prepare: `/spt-redmine-report-prepare`  
4. Draft report: `/spt-redmine-report`  

Command meanings and non-code evidence: [USER_GUIDE.md](../USER_GUIDE.md).

---

## 1. Easiest — `npx skills` (Claude Code · Cursor · Codex)

Needs Node.js. Installs the skill into the right agent folders for you.

**All three agents, global (every project):**

```bash
npx skills add sindevx/spt-redmine-report -g -a claude-code -a cursor -a codex -y
```

**This project only:**

```bash
cd /path/to/your-repo
npx skills add sindevx/spt-redmine-report -a claude-code -a cursor -a codex -y
```

**One agent only** (examples):

```bash
npx skills add sindevx/spt-redmine-report -g -a claude-code -y
npx skills add sindevx/spt-redmine-report -g -a cursor -y
npx skills add sindevx/spt-redmine-report -g -a codex -y
```

Then wire the setup slash command + `local.md`:

```bash
# path may be ~/.claude/skills/redmine-report or ~/.agents/skills/redmine-report or ~/.cursor/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --all
# if that path missing, try:
~/.claude/skills/redmine-report/scripts/install.sh --all
~/.cursor/skills/redmine-report/scripts/install.sh --all
```

In chat:

```text
/setup-spt-redmine-report
```

List skills in a repo without installing: `npx skills add sindevx/spt-redmine-report --list`

---

## 2. Claude Code — plugin marketplace

Inside Claude Code:

```text
/plugin marketplace add sindevx/spt-redmine-report
/plugin install spt-redmine-report@spt-redmine-report
```

Or one shot (Claude Code v2.1.275+):

```text
/plugin install spt-redmine-report --marketplace sindevx/spt-redmine-report
```

From a normal shell:

```bash
claude plugin marketplace add sindevx/spt-redmine-report
claude plugin install spt-redmine-report@spt-redmine-report
```

Then:

```text
/reload-skills
/setup-spt-redmine-report
```

Update later: `/plugin marketplace update spt-redmine-report`

---

## 3. Cursor — plugin / marketplace

### A. From GitHub (Customize)

1. Open **Customize**
2. Import plugin **From GitHub Repository**
3. Paste: `https://github.com/sindevx/spt-redmine-report`
4. Install **spt-redmine-report**
5. New Agent chat → `/setup-spt-redmine-report`

### B. Official Cursor Marketplace (after listing)

When the repo is listed on [cursor.com/marketplace](https://cursor.com/marketplace):

1. **Customize →** search `spt-redmine-report` / Redmine
2. Install → new Agent chat → `/setup-spt-redmine-report`

Authors: submit at [cursor.com/marketplace/publish](https://cursor.com/marketplace/publish) (manual review). Manifests already ship in `.cursor-plugin/`.

### C. Local test before publish

```bash
mkdir -p ~/.cursor/plugins/local/spt-redmine-report
# copy or clone repo contents into that folder (must include .cursor-plugin/plugin.json)
# Developer: Reload Window → Customize → confirm plugin
```

### D. Still fine: `npx skills` (section 1) or personal skills folder

```bash
npx skills add sindevx/spt-redmine-report -g -a cursor -y
```

---

## 4. Codex — skill installer / skills path

```text
$skill-installer install https://github.com/sindevx/spt-redmine-report
```

Or:

```bash
npx skills add sindevx/spt-redmine-report -g -a codex -y
```

Use:

```text
$redmine-report
```

Ask: `setup-spt-redmine-report` if `$` menu has no setup command.

---

## 5. Manual clone (fallback)

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --all
```

| Tool | Flag | Skills path |
|---|---|---|
| Claude Code | `--claude` | `~/.claude/skills/redmine-report` |
| Cursor | `--cursor` | `~/.cursor/skills/` (+ `~/.agents/skills/`) |
| Codex | `--codex` | `~/.agents/skills/redmine-report` |
| All | `--all` | symlinks + setup command |

Project-scoped Claude/Cursor: add `--project` while inside the git repo.

Details and troubleshooting for clone installs: sections below.

---

## Claude Code — clone / project (manual detail)

### Personal

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.claude/skills/redmine-report
~/.claude/skills/redmine-report/scripts/install.sh --claude
```

### Project

```bash
cd /path/to/your-repo
mkdir -p .claude/skills
git clone https://github.com/sindevx/spt-redmine-report.git .claude/skills/redmine-report
.claude/skills/redmine-report/scripts/install.sh --claude --project
```

Check: `/skills` · `/setup-spt-redmine-report` · mid-session → `/reload-skills`

---

## Cursor — clone detail

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.cursor/skills/redmine-report
~/.cursor/skills/redmine-report/scripts/install.sh --cursor
```

Project:

```bash
mkdir -p .cursor/skills
git clone https://github.com/sindevx/spt-redmine-report.git .cursor/skills/redmine-report
```

Start a **new** Agent chat. Confirm under **Customize → Skills**.

Cloud Agents: prefer project `.cursor/skills/` or sync personal skills in Settings.

---

## Codex — clone detail

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --codex
```

Project: `.agents/skills/redmine-report`

---

## After install (all methods)

1. `/setup-spt-redmine-report` (or Codex equivalent)
2. Pick Mode: `report-only` | `mcp` | `manual`
3. Read Setup summary
4. Then ask for a Redmine report

Reset: `/setup-spt-redmine-report reset`

---

## Update

| Method | Update |
|---|---|
| `npx skills` | `npx skills update` (when available) or re-run `npx skills add … -y` |
| Claude marketplace | `/plugin marketplace update spt-redmine-report` |
| Cursor plugin | Update from Customize / re-import |
| git clone | `git pull` then `./scripts/install.sh --all` |

---

## Uninstall

Remove skill folders and setup command:

```bash
rm -rf ~/.agents/skills/redmine-report
rm -rf ~/.claude/skills/redmine-report
rm -rf ~/.cursor/skills/redmine-report
rm -f ~/.claude/commands/setup-spt-redmine-report.md
rm -f ~/.cursor/commands/setup-spt-redmine-report.md
```

Claude plugin: `/plugin uninstall spt-redmine-report@spt-redmine-report`  
Cursor: remove from Customize → Skills / Plugins.

---

## Common mistakes

| Mistake | Fix |
|---|---|
| Extra nesting (`…/redmine-report/redmine-report/SKILL.md`) | `SKILL.md` must sit directly in the skill folder |
| Folder named `spt-redmine-report` under skills/ | Prefer folder name `redmine-report` (matches skill `name`) |
| Cursor chat already open | New Agent chat after install |
| Setup never run | `/setup-spt-redmine-report` |
| Expecting Redmine writes from the skill | Drafts only |

Usage: [USER_GUIDE.md](../USER_GUIDE.md)
