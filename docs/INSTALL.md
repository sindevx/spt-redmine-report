# Install — Claude Code, Cursor, Codex

One skill folder. Three agents. Pick your tool below, then run **one-time setup**.

Repo: https://github.com/sindevx/spt-redmine-report  
Skill folder name must stay `redmine-report` (matches `name` in `SKILL.md`).

---

## Quick path (all three on one machine)

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --all
```

What `--all` does:

1. Keeps the skill under `~/.agents/skills/redmine-report` (Codex + Cursor read this)
2. Symlinks the same folder into `~/.claude/skills/` and `~/.cursor/skills/`
3. Installs `/setup-spt-redmine-report` into Claude and Cursor command dirs
4. Creates `local.md` if missing

Then in any agent chat:

```text
/setup-spt-redmine-report
```

Codex: type `$redmine-report` for the skill, or ask to run setup (`setup-spt-redmine-report` / `reset`).

---

## Claude Code

### Personal (every project on this machine)

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.claude/skills/redmine-report
~/.claude/skills/redmine-report/scripts/install.sh --claude
```

### Project (shared with the repo)

```bash
cd /path/to/your-repo
mkdir -p .claude/skills
git clone https://github.com/sindevx/spt-redmine-report.git .claude/skills/redmine-report
.claude/skills/redmine-report/scripts/install.sh --claude --project
```

`--project` installs the setup command into `.claude/commands/` in the repo (commit that file if the team should share it). `local.md` stays personal — it is git-ignored inside the skill folder; for project installs prefer a user-level `local.md` via symlink or run setup once per machine.

### Check

```text
/skills
/setup-spt-redmine-report
```

If the skill was added mid-session and does not appear: `/reload-skills`.

### Use

```text
/setup-spt-redmine-report
make a redmine report for this release
```

---

## Cursor

Cursor loads skills from (among others):

| Scope | Path |
|---|---|
| Personal | `~/.cursor/skills/` or `~/.agents/skills/` |
| Project | `.cursor/skills/` or `.agents/skills/` |
| Compatibility | also `~/.claude/skills/` |

### Personal

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.cursor/skills/redmine-report
~/.cursor/skills/redmine-report/scripts/install.sh --cursor
```

Or use the shared agents path (good if you also use Codex):

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --cursor
```

### Project

```bash
cd /path/to/your-repo
mkdir -p .cursor/skills
git clone https://github.com/sindevx/spt-redmine-report.git .cursor/skills/redmine-report
.cursor/skills/redmine-report/scripts/install.sh --cursor --project
```

### Check

1. Start a **new** Agent chat (skills are discovered at session start)
2. Open **Customize → Skills** and confirm `redmine-report`
3. Type `/` and pick `setup-spt-redmine-report`, or type:

```text
/setup-spt-redmine-report
```

Cloud Agents do not see laptop-only `~/.cursor/skills/` unless you sync personal skills or put the skill under the repo’s `.cursor/skills/`.

---

## Codex (OpenAI)

Codex loads:

| Scope | Path |
|---|---|
| Personal | `~/.agents/skills/` |
| Project | `.agents/skills/` (from CWD up to repo root) |

Legacy `~/.codex/skills/` may still be read; prefer `~/.agents/skills/`.

### Personal

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --codex
```

### Project

```bash
cd /path/to/your-repo
mkdir -p .agents/skills
git clone https://github.com/sindevx/spt-redmine-report.git .agents/skills/redmine-report
.agents/skills/redmine-report/scripts/install.sh --codex
```

### Check / use

```text
$redmine-report
```

Or ask in plain language: `run setup for spt-redmine-report`.

Codex has no Claude-style `/setup-...` menu by default. Setup is still the same flow: the skill writes `local.md` when you ask for `/setup-spt-redmine-report` or `setup-spt-redmine-report`.

Optional curated installer (if available in your Codex build):

```text
$skill-installer install https://github.com/sindevx/spt-redmine-report
```

Then move/rename the folder to `redmine-report` if the installer used another name, and run `scripts/install.sh --codex`.

---

## After install (all tools)

1. Run setup once:

```text
/setup-spt-redmine-report
```

2. Pick Mode: `report-only` (safe default), `mcp`, or `manual`
3. Read the **Setup summary** the agent prints (also stored in `local.md`)
4. Only then ask for a Redmine report

Reset:

```text
/setup-spt-redmine-report reset
```

---

## Update

```bash
# wherever you cloned it
cd ~/.agents/skills/redmine-report   # or ~/.claude/skills/... or ~/.cursor/skills/...
git pull
./scripts/install.sh --all           # refresh slash command copies
```

---

## Uninstall

```bash
rm -rf ~/.agents/skills/redmine-report
rm -rf ~/.claude/skills/redmine-report
rm -rf ~/.cursor/skills/redmine-report
rm -f ~/.claude/commands/setup-spt-redmine-report.md
rm -f ~/.cursor/commands/setup-spt-redmine-report.md
```

Remove project copies under `.claude/skills/`, `.cursor/skills/`, or `.agents/skills/` if you added those.

---

## Common mistakes

| Mistake | Fix |
|---|---|
| Extra nesting (`.../spt-redmine-report/redmine-report/SKILL.md`) | `SKILL.md` must be directly inside `.../redmine-report/` |
| Wrong folder name | Must be `redmine-report`, not `spt-redmine-report` |
| Cursor chat already open | Start a new Agent chat after install |
| Claude mid-session | `/reload-skills` |
| Setup never run | `/setup-spt-redmine-report` before any report |
| Expecting Redmine writes from the skill | Drafts only; push is a separate companion step |

More usage detail: [USER_GUIDE.md](../USER_GUIDE.md).
