# User guide — redmine-report

This guide is for people installing and using the skill. Agent rules live in `SKILL.md`. Deep rules live in `references/full-rules.md`.

## What you get

A **draft Redmine report** from finished work. Evidence can come from **many sources** — not only source code:

- Vendor / partner API documents and Postman collections  
- Owner notes, meeting minutes, analysis hours (no commit)  
- Redmine parent/sibling issues (read-only)  
- Specs, ADRs, handover docs, UAT logs  
- And code/tests when they exist  

The skill **never creates or updates Redmine issues by itself**. You review files first. Push is optional (companion skill + plain `confirm`).

---

## Slash commands (`/` menu)

After `scripts/install.sh`, these show up when you type `/`:

| Command | When to use | Output |
|---|---|---|
| `/setup-spt-redmine-report` | **First time** (or after reset). Mode, MCP, trackers → `local.md` | Setup summary |
| `/setup-spt-redmine-report reset` | Change Mode/MCP/instance map | New setup |
| `/spt-redmine-report-prepare` | **Prepare data** from docs, Postman, Redmine, notes — **before** a full report; code optional | `.scratch/<feature>/redmine-report-prepare.md` |
| `/spt-redmine-report` | **Draft the Redmine report** (table + notes). Uses prepare pack if present | `redmine-report.md` + `redmine-report-notes.md` |

Codex: use `$redmine-report` or type the same names without `/` if the menu differs.

### Typical flows

**A. Code-heavy release (default)**

```text
/setup-spt-redmine-report          # once
/spt-redmine-report                # or: /spt-redmine-report release
```

**B. Vendor API / document work (not “just read code”)**

```text
/spt-redmine-report-prepare vendor doc
# point at Postman collection, PDF/MD API doc, or paste
/spt-redmine-report
```

**C. Notes / support / investigation (little or no code)**

```text
/spt-redmine-report-prepare notes
# paste meeting notes, ticket text, or a file path
/spt-redmine-report
```

**D. Align with an existing Redmine story**

```text
/spt-redmine-report-prepare redmine 12345
/spt-redmine-report story 12345
```

(Mode `mcp` required for live Redmine reads.)

You can still use plain language (`make a redmine report for this release`) — the `/` commands are the clear, repeatable entry points.

---

## Evidence sources (not code-only)

| Source | Prepared by | Used for |
|---|---|---|
| Current code + tests | `/spt-redmine-report` | What the software does now |
| Git branch / tag / release range | `/spt-redmine-report` | When files changed (hint, not sole proof) |
| Vendor / partner API doc | `/spt-redmine-report-prepare` | Endpoints, scenarios → UAT checklist |
| Postman / Insomnia collection | `/spt-redmine-report-prepare` | Scenarios, sample payloads, dates |
| Owner words (hours, analysis day, UAT result) | either command | Work with **no** commit |
| Spec / ADR / handover / meeting notes | `/spt-redmine-report-prepare` | Business intent, timeline |
| Redmine parent or sibling issue | `/spt-redmine-report-prepare redmine <id>` | Title style, hours, hierarchy |
| UAT logs / saved API responses | `/spt-redmine-report-prepare` | Test proof |
| Chat paste / attached file | `/spt-redmine-report-prepare` | Anything not in the repo yet |

**Rule:** commit messages are claims. Artefacts above are proof. A valid report can be mostly non-code when the work was analysis, support, or document-driven integration.

Set `Vendor doc path hint` in `local.md` during setup if you often use the same folder (e.g. `postman/*`).

---

## Requirements

- One of: **Claude Code**, **Cursor**, or **Codex**
- Working folder for the project (repo optional for prepare-only, recommended for report)
- Python 3 (for the report checker)
- Optional: Redmine MCP (Mode `mcp`)

## Install

**Full options:** **[docs/INSTALL.md](docs/INSTALL.md)**.

```bash
npx skills add sindevx/spt-redmine-report -g -a claude-code -a cursor -a codex -y
# then from the installed skill folder:
./scripts/install.sh --all
```

That installs **all** slash commands (`setup`, `prepare`, `report`).

## One-time setup

```text
/setup-spt-redmine-report
```

| Mode | When | Redmine |
|---|---|---|
| `report-only` | Default / safest | No calls — drafts only |
| `mcp` | Live sibling/parent reads | Read during prepare/report; write only via companion + `confirm` |
| `manual` | No MCP | You paste tracker names once |

After setup, `local.md` holds Mode, MCP name, trackers, statuses, custom fields, and a **Setup summary**.

## Everyday use

### 1) Optional — prepare evidence

```text
/spt-redmine-report-prepare
```

Answer which sources to use. Get `redmine-report-prepare.md`.

### 2) Draft the report

```text
/spt-redmine-report
```

Answer scope, parent id, one-sentence summary, analysis hours, flat vs task groups, production impact.  
Say `default` when `local.md` values are fine.

### Output files

Under `.scratch/<feature>/`:

| File | Purpose |
|---|---|
| `redmine-report-prepare.md` | Evidence pack (from prepare) — not pushed |
| `redmine-report.md` | What you would send to Redmine |
| `redmine-report-notes.md` | Full evidence — **not** pushed |

### Checker

```bash
python3 ~/.claude/skills/redmine-report/scripts/check_report.py \
  .scratch/<feature>/redmine-report.md --story-hours <hours>
```

Aim for `RESULT: PASS`.

### Review and push

1. Read chat summary + open the files.  
2. Answer open questions.  
3. `report-only` / `manual`: paste into Redmine yourself.  
4. `mcp` + companion: review → type exactly `confirm` → push.

`ok` / `ok go` / `create it` are **not** confirm.

## Tips

- Prefer business wording in subjects (no class names or hashes in the sent file).  
- Spent hours are a proposal — you confirm before time entries.  
- UAT / production stay open until you say they ran.  
- Prepare first when the main input is a document or notes, not a diff.

## Troubleshooting

| Problem | What to do |
|---|---|
| `/` commands missing | `./scripts/install.sh --all` |
| No report without setup | `/setup-spt-redmine-report` |
| “It only looked at code” | Run `/spt-redmine-report-prepare` with your doc/notes first |
| MCP probe fails | Mode `report-only` or fix auth |
| Checker `ERROR` | Fix hours/dates/descriptions in the table |

## Layout of this repo

| Path | Role |
|---|---|
| `SKILL.md` | Agent rules for the full report |
| `USER_GUIDE.md` | This guide |
| `docs/INSTALL.md` | Install (npx / marketplace / clone) |
| `commands/setup-spt-redmine-report.md` | `/setup-spt-redmine-report` |
| `commands/spt-redmine-report-prepare.md` | `/spt-redmine-report-prepare` |
| `commands/spt-redmine-report.md` | `/spt-redmine-report` |
| `scripts/install.sh` | Installs skill links + all `/` commands |
| `local.example.md` | Template for `local.md` |

## Privacy

Keep MCP names, project ids, and instance details in `local.md` only (git-ignored).
