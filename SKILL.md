---
name: redmine-report
description: This skill should be used when the user runs /spt-redmine-report, /spt-redmine-report-prepare, or /setup-spt-redmine-report, or asks to prepare a Redmine report, story, epic, or task breakdown from finished work. Evidence may come from vendor docs, Postman, Redmine issues, owner notes, specs, UAT logs, and code — not code alone. Writes draft files and checks them. Never writes to Redmine; pushing is a separate companion step afterwards.
---

# Redmine Release Report

Prepare a Redmine report a manager can read and the owner can approve. The report is ready when the checker prints `RESULT: PASS` and the owner has answered every open question.

Detail for every rule below: `references/full-rules.md`. Read only the part needed; do not load it whole. Human install, slash commands, and multi-source evidence: `USER_GUIDE.md`.

## Slash commands

| Command | Role |
|---|---|
| `/setup-spt-redmine-report` | One-time setup → `local.md` |
| `/spt-redmine-report-prepare` | Evidence pack from docs/Postman/notes/Redmine — **code optional**. Follow `commands/spt-redmine-report-prepare.md` |
| `/spt-redmine-report` | Full draft report. Follow `commands/spt-redmine-report.md` + steps below |

If the user runs prepare, write the prepare file and stop unless they also ask for the report.

## Step 0. One-time setup (slash command)

**Preferred entry:** `/setup-spt-redmine-report` (optional `reset`). Follow `commands/setup-spt-redmine-report.md` — setup only, no report draft.

Done when `local.md` exists, `Setup completed` has a date, and `Setup summary` is non-empty.

If the user asks for a report but setup is incomplete: **do not guess**. Tell them to run `/setup-spt-redmine-report` first (after `./scripts/install.sh` if slash commands are missing).

Never invent an MCP server name. Never bake instance ids into this skill. Only `local.md` holds machine-specific values.

If a companion task skill is installed, keep the MCP server name identical in both local configs.

## Step 1. Ask once per report

Send this block in one message and wait. Defaults from `local.md` count only if the owner says "default".

1. Story id and parent id (if any). Server/MCP from `local.md` — do not re-ask unless the owner overrides for this run.
2. What was the work? One sentence from the owner.
3. Day the vendor document or request arrived (if any), and real hours for analysis/design with no commit.
4. Flat tasks with a Phase column, or task groups like a sibling story?
5. Assignee (default from `local.md`, else the owner) and any custom-field values required by `local.md`.
6. Does this change something already in production? (yes = add a Review & Production Impact story)
7. Which evidence sources apply this time? (code / vendor doc / Postman / notes / Redmine sibling / UAT logs — multi-select). If a prepare pack exists under `.scratch/`, offer to use it.

## Step 2. Read the evidence (multi-source — not code-only)

Done when each task row has at least one evidence line in the notes file. **Do not skip non-code sources** when the owner named them or a prepare pack exists.

- **Prepare pack** (if `.scratch/<feature>/redmine-report-prepare.md` exists): treat it as primary input; extend with code only where needed.
- **Code + tests:** entry points, checks, mapping. Commit messages are claims; current code is proof.
- **Vendor / partner document or Postman:** list endpoints and scenarios → UAT checklist. Path hint from `local.md` or owner paste.
- **Owner words:** analysis/design hours, arrival day, UAT results — required when there is no commit.
- **Sibling / parent Redmine** (Mode `mcp`): title length, hours style, hierarchy.
- **Spec / ADR / handover / meeting notes / UAT logs / saved responses:** dates and business intent.
- Dates: prefer artefacts above over `git log` alone. Working days only; tasks in order.

## Step 3. Shape tasks in life-cycle order

Done when Phase runs: Analysis, Design, Implement (one task per endpoint or business function), Test, UAT, Production.
- Analysis/design may have no commit — mark "owner confirms", use hours from Step 1.
- UAT and Production start as New; description starts with `Plan:`. Production waits on UAT sign-off.
- One task = one real activity. Size follows the diff and sibling style. Small task: 0.25h or 0.5h. Total equals story hours.

## Step 4. Write two files

Done when both exist under `.scratch/<feature>/`. Nothing from the notes file goes to Redmine.
- `redmine-report.md` (sent): story text, one table, open questions, push order.
  Columns: `ID | Tracker | Subject | Description | Priority | Status | Done % | Est. h | Spent h* | Start | Due` (+ custom-field columns only when `local.md` defines them).
- `redmine-report-notes.md` (not sent): evidence, flow, endpoints, size evidence, date sources, tests, risks, vendor scenarios.
- Business words only. Subject starts with an action verb. Description 1–3 plain past-tense lines. No class names, hashes, or file paths in the sent file.
- Spent h* is a proposal ≤ estimate (often 0.5–1.0×). Identical spent on every row looks fake. Owner confirms before any time entry.

## Step 5. Run the checker

```
python3 ~/.claude/skills/redmine-report/scripts/check_report.py .scratch/<feature>/redmine-report.md --story-hours <hours>
```

Done on `RESULT: PASS`. Fix every `ERROR`; read every `WARN`.
- No task marked Closed until the test command from `local.md` has run (or owner accepts skip). Record the real result in the notes file.

## Step 6. Review with the owner

Short summary + file path in chat, not the whole payload. Done when open questions are answered.
- `report-only` / `manual`: stop after file approval.
- `mcp` + companion push skill: hand off for review → plain `confirm` → push → read back.
- Redmine calls alone in a response — never batched with a shell call that a hook may rewrite.
- This skill never POST/PUT to Redmine.

## Learn from problems

Fix the report first, then patch the matching rule in this skill (replace the old line; do not stack a duplicate). Optional short note under Preferences in `local.md`.
