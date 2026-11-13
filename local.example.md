# Local settings (personal, git-ignored)
# Create via: scripts/install.sh
# Fill via slash command: /setup-spt-redmine-report
# Reset: /setup-spt-redmine-report reset
# Later reports read this file only — do not re-ask setup while Setup completed is set.

## Setup status
Setup completed:              # YYYY-MM-DD when Step 0 finished; empty = setup required
Setup summary:                # 5–10 line human summary written after probe (so the owner can re-read details)

## Redmine connection
# Mode: mcp | report-only | manual
#   mcp         — use the named MCP server for read (push stays with companion skill if installed)
#   report-only — write draft files only; never call Redmine
#   manual      — no MCP; owner pastes tracker/status names when asked
Mode: report-only
MCP server:                   # exact MCP namespace/name on this machine; required when Mode is mcp

## Instance map (filled once during setup; do not guess later)
Default project id:
Default project name:
Trackers:                     # name=id pairs from /trackers.json (or owner paste in manual mode)
Statuses:                     # name=id pairs from /issue_statuses.json
Priorities:                   # name=id pairs from enumerations
Activities:                   # name=id for time entries
Versions note:                # how this project uses versions / target versions, or "none"
Done status:                  # status name+id used for finished work (e.g. Closed)
New status:                   # status name+id for not-started work
Hierarchy note:               # how parent_issue_id is used (e.g. Story→Task, or Epic→Story→Task)

## Custom fields
# List each field used in reports: name, id, required yes/no, default, notes.
# Use "none" when the instance has no custom fields needed for reports.
Custom fields: none

## Report defaults
Assignee: owner               # owner | fixed display name
Test command: none            # none | project test command (owner supplies)
Vendor doc path hint:         # optional glob, e.g. postman/* — empty if unused
Sibling style issue id:       # optional finished issue to copy title/hours style from

## Companion
# If another skill pushes to Redmine, keep the MCP server name identical there.
Companion MCP aligned: no     # yes when checked

## Preferences (max 10 lines)
# Language, flat vs task-groups default, etc.
