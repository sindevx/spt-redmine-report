---
description: Draft a Redmine report from finished work (multi-source evidence, not code-only)
argument-hint: "[release|branch|story <id>|feature <name>]"
---

# /spt-redmine-report

User invoked: `/spt-redmine-report $ARGUMENTS`

Run the **redmine-report** skill to draft a Redmine report. Follow `SKILL.md` in the skill home.

Skill home (first path that exists):

- `~/.claude/skills/redmine-report`
- `~/.agents/skills/redmine-report`
- `~/.cursor/skills/redmine-report`

## Preconditions

If `local.md` has no `Setup completed` date: stop and tell the owner to run `/setup-spt-redmine-report` first.

## What to do

1. Parse `$ARGUMENTS` as scope hint (release range, branch name, story id, feature slug). If empty, ask Step 1 questions from `SKILL.md`.
2. Collect evidence from **all relevant sources** (not commits alone). See Evidence rules below.
3. Write `.scratch/<feature>/redmine-report.md` and `redmine-report-notes.md`.
4. Run `scripts/check_report.py` until `RESULT: PASS` (or list remaining ERRORS).
5. Show a short summary + file paths. Do **not** POST/PUT to Redmine.

## Evidence rules (mandatory)

Every task row needs at least one evidence line in the notes file. Prefer several sources when they exist:

| Source | Use when |
|---|---|
| Current code + tests | Behaviour that shipped or will ship |
| Git range / branch / tag | When the work changed; never the only proof |
| Vendor / partner API doc or Postman collection | Integration work; scenarios → UAT checklist |
| Owner words (hours, analysis days, UAT results) | Work with no commit (analysis, design, meetings) |
| Redmine sibling / parent (Mode `mcp`) | Title style, hours size, hierarchy |
| ADR / spec / handover / meeting notes in repo | Business intent and dates |
| Saved API responses, UAT logs, screenshots paths | Test/UAT proof |
| Pasted notes or files the owner attaches in chat | Anything not in the repo yet |

Commit messages are **claims**. Code and other artefacts are **proof**. If only non-code sources exist (support ticket, data fix, investigation), still draft the report from those sources and mark gaps under open questions.

## After draft

Hand off to companion push only if the owner asks and Mode is `mcp`. Confirm word must be plain `confirm`.
