# redmine-release-report

A Claude Code skill that turns finished git commits, a release diff, or a feature branch into a Redmine-ready report — business-level story/epic description plus technical subtasks, with real dates and hour estimates pulled from git history.

## Install

Copy `SKILL.md` into your skills directory:

```bash
git clone git@github.com:sindevx/redmine-report-skills.git ~/.claude/skills/redmine-release-report
```

Works with any Claude Code runtime that reads `~/.claude/skills/` (or the cross-runtime alias `~/.agents/skills/`).

## What it does

Given "make a redmine report for this release", it:

1. Asks two questions first — report scope (whole release vs one feature), and whether you already have a parent issue assigned — instead of guessing
2. Finds the right commit range (last tag → HEAD, falling back to the last release-merge commit, or asks you)
3. Reads every commit for real and classifies it (feature / bug / chore / docs-excluded / needs-manual-review)
4. Writes two altitudes of description: business language for the story/epic, technical detail for subtasks
5. Pulls real Start/Due dates and traceable `Source` (commit hash or design doc) — never invents evidence
6. Detects your Redmine's actual tracker/version setup via MCP (or asks) instead of assuming an Epic/Story/Task hierarchy exists
7. Outputs one table you paste into Redmine yourself — it does not create issues unless you explicitly ask it to

See `SKILL.md` for the full step-by-step and the common-mistakes table.

## Why

Redmine has no built-in Epic/Story/Task levels like Jira — `tracker` is just a type label, and the real hierarchy is `parent_issue_id`. Every instance's tracker names differ. This skill treats that as a fact to check, not an assumption to bake in.

## License

MIT — see `LICENSE`.
