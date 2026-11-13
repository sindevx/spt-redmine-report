---
description: Prepare evidence pack from docs, Postman, Redmine, notes — before or without a full report
argument-hint: "[vendor doc|postman|redmine <id>|notes|path]"
---

# /spt-redmine-report-prepare

User invoked: `/spt-redmine-report-prepare $ARGUMENTS`

**Prepare data only.** Do not write the full Redmine push table unless the owner also asks for a report. Goal: one evidence pack the report step can reuse.

Skill home (first path that exists):

- `~/.claude/skills/redmine-report`
- `~/.agents/skills/redmine-report`
- `~/.cursor/skills/redmine-report`

## Preconditions

Setup should exist (`/setup-spt-redmine-report`). If missing, say so once; still allow a local evidence pack under `.scratch/` when the owner only wants prep.

## What to do

1. Ask what sources to use (or take `$ARGUMENTS`):
   - Vendor / partner API document (path or paste)
   - Postman / Insomnia collection
   - Redmine issue or sibling id (Mode `mcp` → read-only GET)
   - Owner notes, meeting minutes, email summary (paste or file path)
   - Spec / ADR / handover markdown in the repo
   - UAT log / saved responses
   - Optional: code area or branch to cross-check later
2. Read those sources. **Do not require a git diff.** Code is optional for this command.
3. Write `.scratch/<feature>/redmine-report-prepare.md` with:

```markdown
# Evidence pack — <feature>

## Sources used
- ...

## Work summary (1–3 lines, business language)

## Timeline / dates found
| Date | What | Source |

## Endpoints / scenarios (if API work)
| Name | Method/path or scenario | Notes |

## Suggested life-cycle tasks (draft titles only)
| Phase | Suggested subject | Evidence | Est. h? |

## Owner hours / analysis (no commit)
- Ask or record...

## Gaps / open questions
- ...

## Ready for report?
- Yes → owner should run `/spt-redmine-report`
- No → list what is still missing
```

4. Show the file path and a short summary. Stop.

## Rules

- Never invent endpoints, hours, or UAT results.
- Never POST/PUT Redmine from this command.
- Prefer business wording in suggested subjects.
- If the owner says "also make the report", continue with `/spt-redmine-report` using this pack as the primary evidence input.
