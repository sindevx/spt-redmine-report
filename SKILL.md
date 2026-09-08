---
name: redmine-release-report
description: Use when asked to turn finished git commits, a release diff, or a feature branch into a Redmine report, story, epic, or task breakdown — before creating or estimating Redmine issues for completed development work.
---

# Redmine Release Report

## Overview
Turns real git history (commits, diffs, dates) into a Redmine-ready report: business-level story/epic description plus technical subtasks with hours and dates. Never invents scope — always confirms against what the user's Redmine instance and any boss-assigned issue actually say.

## When to Use
- "make a redmine report for this release"
- "write story/task for what we just shipped"
- "how do I file this in redmine, what levels (epic/story/task)"

Not for auto-creating issues by default — this skill produces a report. Pushing to Redmine is a separate step the user must explicitly ask for.

## Step 0 — Ask before touching git or Redmine

Two questions, one at a time:

1. **Scope** — whole release (many commits/features bundled) or one dev section (single feature/task)?
2. **Existing parent issue** — does the user already have a story/epic/task assigned (e.g. by a manager)? If yes, get its id and, when a Redmine MCP tool is available, fetch its real subject/description/acceptance criteria before writing anything — build only the subtasks that fit under it, don't duplicate the story. If no, this skill builds the story/epic from scratch.

Skipping this and guessing scope, or re-deriving a story that already exists, is the most common failure — verified: an earlier run of this exact task drafted full stories before asking, and had to redo the breakdown once scope and an assigned-issue question came up.

## Step 1 — Find the commit range

Fallback chain, in order:
1. Latest git tag → HEAD (`git tag --list`, `git log <tag>..HEAD`)
2. No tags: latest merge commit whose message contains "release"
3. Neither found: ask the user for the exact start/end ref — never guess a range

## Step 2 — Read every commit for real, classify by purpose

`git log <range> --oneline --no-merges`, then `git show --stat` (full diff for anything non-trivial) per commit. Classify:
- **feature** — new capability
- **bug** — fixes wrong behavior; flag `production risk` if it touches prod config, a data type, or security
- **chore/build** — tooling only, no runtime behavior change
- **docs** — exclude from the story list entirely (people reading Redmine don't read code; doc-only commits carry no story value)

A commit that matches none of these (no clear intent, no conventional-commit prefix) does not get force-classified — list it under "needs manual review" at the end instead of guessing.

## Step 3 — Write records at two altitudes, never mixed

- **Story/Epic description** — business language only: what the user/partner/ops gets and why it matters. No method names, class names, or file paths.
- **Subtask description** — technical detail: which layer changed, what validation rule, what was tested.

Anything touching production config, credentials, or auth gets Priority=High plus a one-line risk note.

Never copy raw diff text or config values into a description — passwords, tokens, connection strings show up in real diffs (verified in this kind of repo's own `application-*.properties` files). Summarize the change; never paste the literal secret value.

## Step 4 — Dates and hours

- **Start Date** = earliest evidence: a design doc's own date if one exists, else commit author date (`git show -s --format=%ai <hash>`)
- **Due/Finish Date** = commit date for already-done work; for "build & UAT" / "deploy production" keep Due after Start and note production is gated on UAT sign-off
- **Est. Hours** = best-effort per subtask, always labeled an estimate — git has no time log; tell the user to adjust to actual spent hours before entering into Redmine

Always split **build & UAT** and **deploy production** into separate subtasks, production explicitly gated on UAT passing. Never one combined "deploy" line.

## Step 5 — Match the user's Redmine, don't assume Jira-style levels

Redmine has no built-in Epic/Story/Task hierarchy — `tracker` is just a type label; the real hierarchy is `parent_issue_id`, settable on any tracker regardless of name. Don't assume an "Epic" tracker exists.

- Redmine MCP available → call `/trackers.json` and `/versions.json` for real, propose a mapping (e.g. "this instance has no Epic tracker, use `parent_issue_id` under UserStory/Task instead"), get the user to confirm it
- No MCP → ask the user what their tracker names are; never hardcode one instance's tracker names/ids into a report meant for someone else's Redmine

## Output format

One table, one row per record: `ID | Tracker | Parent | Subject | Description | Priority | Est. Hours | Start Date | Due/Finish Date | Status | Source`. `Source` = commit hash or design-doc path, so every row traces to real evidence. State the total record count up top, e.g. "12 records: 1 Story + 8 Subtask + 2 Bug + 1 Task".

Report only — never call a Redmine write endpoint unless the user explicitly asks for auto-creation in that conversation.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Assuming Epic/Story/Task exists in Redmine | Check `/trackers.json` first, or ask |
| Story description has class/method names | Business language for story; technical detail only in subtasks |
| Building a new story when one is already assigned | Ask Step 0 first, every time |
| Pasting raw config diff (passwords, tokens) into a report | Summarize the change, redact the value |
| One combined "deploy" task | Split UAT and production; production gated on UAT |
| Guessing the commit range | Tag → release-merge commit → ask, in that order |
| Force-classifying every commit into feature/bug/chore | Unclear commits go to "needs manual review" |
