# User guide — redmine-report

This guide is for people installing and using the skill. Agent rules live in `SKILL.md`. Deep rules live in `references/full-rules.md`.

## What you get

A **draft Redmine report** from finished work (commits, a branch, a release diff, or a vendor API document):

- Business-level story text a manager can read
- Technical tasks in life-cycle order (Analysis → Design → Implement → Test → UAT → Production)
- Hours and dates tied to evidence, not invented scope

The skill **never creates or updates Redmine issues by itself**. It writes files you review. Pushing (if you want that) is a separate step with a companion skill, after you type a plain `confirm`.

## Requirements

- One of: **Claude Code**, **Cursor**, or **Codex**
- Git repo with the work you are reporting
- Python 3 (for the report checker)
- Optional: a Redmine MCP server on your machine (only if Mode is `mcp`)

## Install

**Per-tool steps (Claude Code / Cursor / Codex):** see **[docs/INSTALL.md](docs/INSTALL.md)**.

All three on one machine:

```bash
git clone https://github.com/sindevx/spt-redmine-report.git ~/.agents/skills/redmine-report
~/.agents/skills/redmine-report/scripts/install.sh --all
```

| Tool | Install flag | How you start setup |
|---|---|---|
| Claude Code | `--claude` | `/setup-spt-redmine-report` |
| Cursor | `--cursor` | `/setup-spt-redmine-report` (new Agent chat) |
| Codex | `--codex` | `$redmine-report` or ask `setup-spt-redmine-report` |

`local.md` is personal and git-ignored. Do not commit it.

## One-time setup

Run this in chat (preferred):

```text
/setup-spt-redmine-report
```

That command asks once, probes when possible, writes `local.md`, and shows a **Setup summary**. Do not start a report until setup finishes.

If the slash command is missing from the picker, re-run `scripts/install.sh`, or type the same text: `setup-spt-redmine-report`.

### Choose a mode

| Mode | When to use | Redmine access |
|---|---|---|
| `report-only` | Default. Safest start. | None — drafts only |
| `mcp` | You have a Redmine MCP and want live reads (sibling issues, trackers). | Read-only during setup/report; write only via companion + confirm |
| `manual` | No MCP, but you know tracker/status names. | You paste names/ids once into `local.md` |

### What gets saved

After setup, open `local.md` and check:

- Mode and MCP server name (if any)
- Default project
- Trackers, statuses, priorities, activities (name=id when known)
- Done / New status
- How parents/children are used (hierarchy note)
- Custom fields (or `none`)
- Test command for this repo
- **Setup summary** — 5–10 lines you can re-read any time

The skill shows that summary in chat once. Later reports reuse `local.md` and do **not** ask setup again.

### Reset setup

```text
/setup-spt-redmine-report reset
```

Clears setup fields and runs setup again.

## Everyday use

### Start a report

In the project repo, say something like:

- `make a redmine report for this release`
- `write Redmine story/tasks for what we just shipped`
- `prepare a redmine-report for branch feature/x`

Answer the per-report questions (scope, parent issue, one-sentence summary, hours without commits, flat vs task groups, production impact).

Say `default` when a value from `local.md` is fine.

### Output files

Under `.scratch/<feature>/`:

| File | Purpose |
|---|---|
| `redmine-report.md` | What you would send to Redmine (story + table) |
| `redmine-report-notes.md` | Evidence, risks, date sources — **not** pushed |

### Checker

```bash
python3 ~/.claude/skills/redmine-report/scripts/check_report.py \
  .scratch/<feature>/redmine-report.md --story-hours <hours>
```

Aim for `RESULT: PASS`. Fix every `ERROR`. Read every `WARN`.

### Review and push

1. Read the short chat summary and open the two files.
2. Answer open questions.
3. If Mode is `report-only` or `manual`: copy into Redmine yourself, or stop.
4. If Mode is `mcp` and a companion push skill is installed: follow its review → type exactly `confirm` → push → read-back.

`ok`, `ok go`, or `create it` are **not** confirm.

## Tips for good reports

- Commit messages are claims; **current code** is proof.
- Prefer business wording in subjects/descriptions (no class names or hashes in the sent file).
- Spent hours are a proposal — you confirm before any time entry.
- UAT and production stay open until you say they ran.
- Keep MCP server names identical if another skill also talks to Redmine.

## Troubleshooting

| Problem | What to do |
|---|---|
| Slash command missing | Re-run `scripts/install.sh` |
| Skill refuses to draft a report | Run `/setup-spt-redmine-report` until Setup summary exists |
| Skill asks setup every time | Check `local.md`: `Setup completed` needs a date and `Setup summary` must be non-empty |
| MCP probe fails | Fix auth, or switch Mode to `report-only` / `manual` |
| Wrong trackers/statuses | Edit `local.md`, or run `/setup-spt-redmine-report reset` |
| Checker `ERROR` | Fix the table (hours, dates, missing description, code names in subject) |
| Want to change Mode later | Edit `Mode` / `MCP server` in `local.md`, or reset setup |

## Layout of this repo

| Path | Role |
|---|---|
| `SKILL.md` | Instructions the agent follows |
| `USER_GUIDE.md` | This guide (humans) |
| `docs/INSTALL.md` | Install for Claude Code, Cursor, Codex |
| `commands/setup-spt-redmine-report.md` | Slash command source (`/setup-spt-redmine-report`) |
| `scripts/install.sh` | `--claude` / `--cursor` / `--codex` / `--all` |
| `local.example.md` | Template for your `local.md` |
| `references/full-rules.md` | Detailed rules (loaded on demand) |
| `scripts/check_report.py` | Validates the report table |
| `tools/check.sh` | Keeps shipped files free of personal/org defaults |

## Privacy

Ship only the skill files. Keep instance URLs, API identities, project ids, and MCP names in `local.md` on your machine.
