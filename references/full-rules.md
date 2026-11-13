<!-- Full rules and lessons. The short checklist is ../SKILL.md. Read only the part you need. -->
---
name: redmine-report
description: Use when asked to turn finished git commits, a release diff, or a feature branch into a Redmine report, story, epic, or task breakdown — before creating or estimating Redmine issues for completed development work.
---

# Redmine Release Report

## Overview
Turns real git history (commits, diffs, dates) into a Redmine-ready report: business-level story/epic description plus technical subtasks with hours and dates. Never invents scope — always confirms against what the user's Redmine instance and any boss-assigned issue actually say.

**Everything below is a default, not a script (owner rule 2026-10-13, L-24).** First pick the scenario (Step 0b), then read the real evidence (code, git, the team's own Redmine style, the owner's words) and shape the tickets to fit. Names, numbers and examples in this file (story names, hour sizes, tracker ids, project names) are examples from past runs. When a rule does not fit the scenario, say so in the review file, adapt, and ask the owner once. Never copy an example into a new report because it was in this file.

## When to Use
- "make a redmine report for this release"
- "write story/task for what we just shipped"
- "how do I file this in redmine, what levels (epic/story/task)"

Not for auto-creating issues by default — this skill produces a report. Pushing to Redmine is a separate step the user must explicitly ask for.

## Step 0a — One-time setup (local.md) before any Redmine or git work for a report

Read `local.md` next to SKILL.md. Setup is complete only when `Setup completed` has a date and `Setup summary` is non-empty. Otherwise follow SKILL Step 0: copy `local.example.md` if needed, ask Mode + MCP once, probe, write the instance map, show the summary, wait if blanks remain.
- `Mode: mcp` requires a non-empty `MCP server` name chosen by the owner from MCP namespaces on this machine. Never invent the name. Never bake a server name into shipped files.
- `Mode: report-only` — draft files only; no Redmine GET/POST/PUT from this skill.
- `Mode: manual` — no MCP; owner pastes tracker/status names into `local.md` once.
- If a companion task skill exists, keep MCP server name aligned across both local configs.
- Later reports read `local.md` and do not re-run setup unless the owner says `reset redmine-report setup`.

## Step 0 — Ask before touching git or Redmine

Present these as a table, not a prose list:

| # | Question | Options |
|---|----------|---------|
| 1 | Scope | Whole release (many commits/features bundled) / One dev section (single feature or task) |
| 2 | Existing parent issue | Yes — give issue id (fetch its real subject/description/acceptance criteria via Redmine MCP when Mode is mcp, then build only the subtasks that fit under it — don't duplicate the story) / No — build the story/epic from scratch |
| 3 | Team style reference | A finished sibling project or phase to copy. Read it first, read-only, see Step 2d (L-22). Skip live read when Mode is not mcp |
| 4 | Does this change something that already runs in production? | Yes — a "Review & Production Impact" story comes first, see Step 2e / No |

Ask all of them before running any git or Redmine command. Skipping this and guessing scope, or re-deriving a story that already exists, is the most common failure — verified: an earlier run of this exact task drafted full stories before asking, and had to redo the breakdown once scope and an assigned-issue question came up.

**Defaults (L-28), so per-report Step 0 is asked once:** Assignee = from `local.md` or the owner; custom fields = from `local.md` or skip when `none`; read the parent first when Mode is mcp (question 2); ask in one message: the day the vendor document arrived, the real hours of analysis and design (they have no commit), and whether the owner wants flat tasks or task groups.

## Step 0b — Pick the scenario, then shape the tickets (L-24)

Detect the scenario from the request, the code and git, and confirm it with the owner in one line. The shape of the tickets, the review and the sizing follow the scenario.

| Scenario | How to detect | Shape of the tickets | Review and impact | Sizing |
|---|---|---|---|---|
| New feature | New code, nothing old replaced | Epic if several functions; Story per business function or per flow step (Step 2f); tasks per real activity | No impact story unless it touches shared production data or config | By lines and difficulty |
| Change or replace a flow that runs in production | Old code removed or behaviour changed | Same as new feature, but a "Review & Production Impact" story first (Step 2e) | Yes: what changes, who is hit, deploy order, rollback | By lines and difficulty; deleting old code is small unless callers change |
| Bug fix or hotfix | Commits fix wrong behaviour | One Bug (or Hotfix) ticket: symptom, root cause, fix, test. No epic | Only when it touches production config, data or security | Small; hours follow the real fix and test |
| Support or data fix, no code change | Steps done by hand or script | One Support ticket: what was asked, what was done, result | Only when data was changed in production | By the real time |
| Release bundle (tag range) | Many commits | One story per business capability; chore and docs left out; unclear commits go to manual review | Per risky item | Per capability |
| Tasks under an existing parent | The owner gives a parent id | Only the tasks that fit under it; do not rebuild the story | Per parent | By lines and difficulty |
| Investigation or spike | Research, no delivered code | One Spike ticket with the question, what was checked, the answer | n/a | By the real time |
| Infrastructure or deploy only | Config, pipeline, servers | Infrastructure ticket(s) per environment, UAT before production | Yes for production | By the real work |
| Integrate a vendor API | The owner got an API document or Postman collection, compared it with the old service, and connected the endpoints to the gateway | Life-cycle tasks: receive the document and list endpoints, analyse what changed against the old service, design routes and checks, one implement task per endpoint, unit tests, vendor-scenario Postman collection, deploy to UAT, test every vendor scenario on UAT, fix defects, production | Yes when it replaces a running flow | By lines and difficulty; analysis hours are the owner's word (L-28) |

If the work mixes scenarios (a new feature that also replaces an old flow), use the strictest rows for the parts that need them. If none fits, describe the work to the owner in one line and ask which shape to use.

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

## Step 2b — Read the real code like a developer (mandatory)

Git log tells WHEN and WHY (commit message). It does not tell WHAT the code does today. Commit messages are claims; the code is the evidence. Before writing any row, open the current source for every feature in scope:

1. Find the entry points: controller, route table, gateway, client, CLI, or job. List each endpoint or entry with method, path, and auth requirement.
2. Trace one request top to bottom: input check, auth/ownership check, downstream call, response mapping, error codes. Read the method bodies, not just names.
3. Record per endpoint: request fields, response fields, validation rules, error codes returned, timeouts, cache keys, DB tables touched, config keys.
4. Read the tests for the feature. Note what is covered and what is not.
5. Read docs/ADR/spec files in the repo for the business reason.
6. Compare with git: a commit that says "feat X" but the code no longer has X (or changed later) is reported by what the code does now. Say so in the row.
7. Anything you could not confirm from code goes to "needs manual review". Never fill it from the commit message alone.
8. **Vendor document (L-28).** When the work follows a vendor document, find it in the repo (`postman/<vendor>*`, `git log -- postman`), list every endpoint and scenario in it with a short script, and make the scenario list the UAT checklist. The date the file entered git is a hint for the start date, not the proof: ask the owner.

Source column for each row = file path + class/method (plus commit hash as secondary evidence).

## Step 2c — Write like a developer's work note (owner rule 2026-10-13, L-20, L-22)

- **Business wording is a hard rule (L-20, L-22, L-28).** The boss must understand every line. Story: business words and Acceptance Criteria. Task description: 1 to 3 plain lines, past tense, saying what the business gets. Plan tasks start with `Plan:`. No class names, method names, commit hashes or file paths in anything that goes to Redmine.
- **Life-cycle order is mandatory (owner rule 2026-11-04, L-27).** Every story's tasks run the full path a real team follows: Analysis, Design, Implement (one task per deliverable), Test (unit tests, Postman), Deploy to UAT, Test on UAT, Fix UAT defects, Deploy to production. Add a Phase column to the table. A report that lists only the implemented code is wrong. Analysis and design tasks with no commit are shown, marked as having no commit, and the owner gives the hours and confirms they happened; planned phases are `New` 0%.
- **One task = one real development activity**, in the order a developer did it. The list depends on the scenario (Step 0b): a new feature may go analyse, spec, create table, implement client, implement endpoint, integrate, unit tests, deploy to UAT, test on UAT; a bug fix goes reproduce, find root cause, fix, test. Use only the activities the evidence shows. Name each by the thing it delivers (for example `Implement <outside service> file upload client`, `Create <result> columns and entity mapping`). Shared code is one task, not one task per layer. Steps not done yet are listed as `New`, 0% (never claim them). Do not invent activities that have no evidence in code, git, notes or the owner's words.
- **Subject** = short, starts with a verb, then the object. Use the verbs and the length the sibling project uses (Step 2d); with no sibling, about 70 characters or less. Not a bare noun, not a code layer alone, not a paragraph.
- **Description is short, like the team writes it.** Story = `Acceptance Criteria:` bullets only. Epic = empty or one line. Task = empty or 1 to 3 plain lines (what was done and the one key rule or risk). No ritual headings (`Business purpose`, `Not checked yet`, `Source`) unless the sibling project uses them. Long detail (field names, tests, risks, evidence) goes in the review `.txt` file for the owner, not into every Redmine task. A long, evenly formatted description on every task reads as generated, not as a developer's note.
- A UAT or test task is written after it ran: what was tested, on which environment, the result, what was fixed. Never write a UAT result the owner did not give.

## Step 2d — Read the team's style first (read-only, before the first draft; L-22)

Ask which sibling project to copy (Step 0, question 3). If the owner names none or none exists, say so in the review file, use the defaults of this skill, and ask once whether to use them. Read the sibling with the Redmine MCP (GET only): the epics, one epic's stories, and one story's tasks. Write down and follow:
- how titles read (verb, length), how long descriptions are, whether epic or task descriptions are empty;
- task size in hours (whole hours? 3 to 5?), the status of finished tasks, stories and epics (for example tasks Closed 100% with spent = estimate, epic In UAT);
- whether parents carry their own estimate, which fixed version or phase is used, who is assigned, which custom fields are set;
- whether stories use task groups (a Task whose children are Tasks): read one story with `GET /issues/<id>.json?include=children` and look at the groups and their leaves (L-26). See "Task groups" in Field standards.
Show the owner a 5-line summary of this style in the review file. Where the style differs from this skill, the sibling project wins, and the difference is one question for the owner.

## Step 2e — Changing something that runs in production: review and impact first (L-22)

When the work replaces or changes existing behaviour, the first story is `Review & Production Impact`. Its tasks, in order: read the old flow and list its problems; read the new API or requirement; write the requirement; assess the impact. The impact task lists, in plain lines: what changes, who is affected, risks (deploy order of database change and app, empty production settings, old data that the new code cannot handle, who can call a new endpoint, credentials), improvements, rollback, and a deploy checklist. Read the code and config to find them; mark what could not be checked. Put the risk list in the task description (short bullets) and the detail in the review file.

## Step 2f — Order the tickets by the real flow (owner rule 2026-10-13, L-23)

Use this when the work is a runtime flow (a request or event passes through steps, for example an approve that calls outside services and stores a result). When it is not (a bug fix, a config change, independent endpoints), group by business function instead (Step 0b). For a flow, trace it once in the code, from the trigger to the stored result, and write it as numbered steps at the top of the review file (trigger, each outside call with its path and what it returns, each database write, what happens on failure, how a retry works). Then:
- One Story per flow step, named in flow order from the real steps (for example `Step 1: <what step 1 does>`, `Step 2: ...`), then retry or error handling, then tests and UAT. The names and the number of steps come from the code you traced, not from this example. A reader must see the flow from the story list alone.
- A step that has its own code and its own outside effect gets its own task. Do not hide steps inside a task called "Integration".
- Inside a story, tasks follow build order (settings, read input, call outside service, check answer, save result, connect to the trigger, tests).
- Put a short "review of the earlier draft" in the file: what was unclear and how the new order fixes it. Reorder as soon as the owner points at the flow.

## Step 3b — Estimate and spent must match the real size of the work (owner rule 2026-10-13)

- Read the size from evidence: lines changed per commit (`git show --shortstat`), number of files, gap between commits of the same day, number of rules. An easy task (one list endpoint that copies a pattern that already exists) gets a small estimate (0.5-1.5h). Only real design work (new client, security rule, cache with fallback) gets 3h or more. Do not give every task the same weight, and do not make an easy task look big.
- **Task size follows the sibling project's style (Step 2d, L-22), but never above the real difficulty (L-23).** Do not lift an easy task up to the team's usual size. There is no minimum: a small task is 15 or 30 minutes (0.25h, 0.5h). Use steps of 0.25h (15 minutes). Merge steps only when they are one piece of work, never to reach a round number (owner rule 2026-10-13, L-25).
- **Boss rule (owner, 2026-10-13, L-23): an easy task that takes many hours means the developer works slowly.** Hours must match difficulty. Calibrate for each report, do not reuse fixed numbers: (a) read a few finished tasks in the sibling project and see what size they give to easy and hard work; (b) ask the owner once how long one easy task and one hard task of this work really took, and scale the rest by lines changed and difficulty; (c) only when there is no calibration, use these defaults and label them "default": a constant, config or one-line fix 0.25 to 0.5h; glue of about 30 lines 0.5h; a new outside client with rules 1 to 2h; a service with several failure paths about 2h; tests about 1h per 100 to 120 lines; deleting old code small unless the callers change. Write the approximate lines changed beside every estimate in the review file ("Size evidence"), so the owner and the boss can see why. When hours per line look high, re-size before showing the draft. Hours are the owner's call: show the proposal as a proposal and say you cannot know the real time.
- Same-day commits give a floor: seven small endpoints committed within 1.5 hours cannot honestly be 4-8h each.
- Spent is the owner's number. The report may show a suggestion taken from commit times, marked `inferred from commits`, and the owner confirms or changes it before it is written. Never write a spent number the owner did not confirm.
- Sanity check before the review: spent / estimate between 0.5 and 1.5 for each done task. Outside that range, show the row with a question mark and ask once.
- A total that looks big for the diff (for example 108h for about 2,000 changed lines) is a sign the estimate is padded. Re-size before showing it.

## Step 3 — Write records at two altitudes, never mixed

- **Story/Epic description** — business language only: what the user/partner/ops gets and why it matters. No method names, class names, or file paths.
- **Subtask description** — technical detail: which layer changed, what validation rule, what was tested.

Anything touching production config, credentials, or auth gets Priority=High plus a one-line risk note.

Never copy raw diff text or config values into a description — passwords, tokens, connection strings show up in real diffs (verified in this kind of repo's own `application-*.properties` files). Summarize the change; never paste the literal secret value.

## Step 4 — Dates and hours

- **Start Date and Due Date (owner rule 2026-11-04, L-29): read them from the repo, not from `git log`.** Order of evidence: (1) a date in a file name (`..._09092026`, `...18092026`) is the day the document arrived; (2) dates written in code comments, tests and ADRs ("UAT 2026-10-12", "decided 2026-09-28"); (3) saved response dates inside the vendor Postman collection (`Date` header, `reqDatetime`) when they come from our own tests, not the vendor's earlier tests; (4) commit dates only as a hint, never as the first or last day of a task, and never when they put a task across months by accident. Keep tasks in order, one developer, working days only (Mon-Fri), start before due, no task that starts and ends on the same day unless it is under 1h. Put a "Date sources" table in the notes file and ask the owner to correct the wrong ones.
- **Due/Finish Date** = commit date for already-done work; for "build & UAT" / "deploy production" keep Due after Start and note production is gated on UAT sign-off
- **Est. Hours** = best-effort per subtask, always labeled an estimate, sized from the real diff (Step 3b). Hours in steps of 0.25 (15 minutes) with no minimum (L-25), one deliverable up to 16h. Add contingency only when the owner asks for it, and only on real work — never on a padded base. Git has no time log, so the estimate is never changed to match spent time. If a companion task skill defines an Estimate rule, follow that when installed.
- **Spent Hours** = the owner's own number, never calculated from commit times. Ask once per record. Empty is shown as `not recorded`. The report may carry a `Spent h*` column as a proposal (L-28): each finished task 1.0 to 1.33 times its estimate, the entry dated on a working day (its due date), open tasks empty. The owner confirms or changes every number before any time entry is written. The Redmine activity is chosen by kind of work (same file, Spent rule).
- **Assignee** = the owner, or the person the owner names. Never empty.
- **Status and Done %** = map from the real state (same file, Field map): finished work follows the sibling story already in Redmine (read one child first): on this server done tasks are `Closed` (5) with 100%, set by a second PUT; planned work is `New` with 0%. Story stays `New` until the owner says otherwise.
- **Custom fields** = only columns listed under Custom fields in `local.md`; omit when `none`.
- **No task is Closed in the report until the project test command from `local.md` has run and its real result is written in the notes file (L-28).** If it was not run, say so and keep the task `Closed (not verified)` in the notes only. Use Done status from `local.md` when set.

Always split **build & UAT** and **deploy production** into separate subtasks, production explicitly gated on UAT passing. Never one combined "deploy" line.

## Step 5 — Match the user's Redmine, don't assume Jira-style levels

Redmine has no built-in Epic/Story/Task hierarchy — `tracker` is just a type label; the real hierarchy is `parent_issue_id`, settable on any tracker regardless of name. Don't assume an "Epic" tracker exists.

- Mode `mcp` and MCP healthy → call `/trackers.json` and `/versions.json` for real, propose a mapping (e.g. "this instance has no Epic tracker, use `parent_issue_id` under UserStory/Task instead"), get the user to confirm it
- Mode `report-only` or `manual`, or MCP down → ask the user what their tracker names are; never hardcode one instance's tracker names/ids into a report meant for someone else's Redmine

## Field standards (owner rule 2026-10-13): title, description, estimate, spent

**Title (subject)**
- Starts with an action verb: Implement / Create / Define / Fix / Test / Deploy / Analyse / Review / Document.
- Then the object; add the one key rule only if the sibling project does. Example: `Implement file upload client`, `Create result table and indexes`.
- About 70 characters or less. No ticket numbers, no dates, no "completed" unless the task is a UAT/test result. Same concept keeps the same name in every task.
- Never a bare noun (`account/info: account detail`).

**Description** (short; match the sibling project, Step 2c)
- Story: `Acceptance Criteria:` bullets only. Epic: empty or one line. Task: empty or 1 to 3 plain lines.
- When more detail is needed (field names, test names, risks, commit hashes), write it in the review `.txt` file, and in the task only if the owner asks.
- A line about tests names real tests that exist. If there is none, say so. Never claim a test or UAT result the owner did not give.
- No secrets, no config values, no real account or customer numbers.
- Story / epic description stays in business language (Step 3). Task description may name the technical piece in plain words.

**Estimate** (hours, steps of 0.25; a small task can be 0.25h or 0.5h, L-25)
- Size from the diff before the first draft is shown: lines, files, rules, new design or copy of an existing pattern.
- Defaults only, replaced by calibration (Step 3b): constant, config or one-line fix 0.25-0.5h. Pattern copy (one more list endpoint) 0.5-1h. One rule or check with tests 0.5-1.5h. New client, security rule, or cache with fallback 1-3h. Over 4h on one task: split it, or the evidence must justify it.
- Never show a padded number and shrink it later. Show the total next to the diff size; if it feels big for the diff, re-size first.
- Parent (story): own estimate = 0 by default. Redmine adds the children, so a non-zero own value counts twice. If the sibling project sets an own estimate on every level, do not decide alone: show both ways in the review file and ask once (L-22). Ask once if the parent already has an estimate.

**Spent** (hours)
- Owner's number only. A suggestion from commit times is allowed if marked `inferred from commits` and the owner confirms before it is written.
- Per task, ratio spent / estimate between 0.5 and 1.5. Outside it: ask once.
- One time entry per task on a working day (the day the work ended). Activity by kind of work (cmd-task.md, Spent rule).
- Story spent: only story-level work (planning, review, Redmine write-up, handover). Never copy the task hours up to the story: Redmine adds children already, so that counts twice. When adding story time, ask if the story estimate rises by the same hours.

**Task groups (owner rule 2026-10-13, L-26)** — use them when the sibling story or the owner's example issue uses them, or when one Story would hold more than about 8 tasks. Ask the owner once if unsure. Pattern read from a live story (Story -> Task group -> Task):
- A group is a Task (tracker Task) whose parent is the Story. Its children are Tasks. Do not make a group a Story.
- Group title = the area as a noun phrase, not a verb: `Analysis and design`, `Project setup`, `Testing and UAT`, `Build and release`. Keep a step number in the title only when the flow order must show (`Upload images to <system> (Step 1)`).
- Group has no own estimate and no own spent (empty). Redmine adds the children. Do not set hours on a group.
- Group description = 2 to 3 plain past-tense sentences of what was done in that area, ending with `Result: ...` (what the business gets). A group that is not finished says what is still planned.
- Group status, % done and dates follow the children; set the group status last. Do not close a group while a child is open.
- Leaf title = verb first, no prefix (the group already names the area). Leaf description = 1 to 2 past-tense sentences (`Built ...`, `Reviewed ...`). A planned, not-done leaf starts with `Plan:`.
- Leaf tracker follows the kind of work: `Bug` for a fix, `Infrastructure` for build, deploy, image or runtime settings, otherwise `Task`.
- Create order: groups first (parent = Story), then leaves (parent = group). To move tickets that already exist, PUT `parent_issue_id`, `subject`, `description`, `tracker_id` and read each one back. Moving or renaming pushed tickets is a re-cut: review file first, then "confirm" (Push rule 13).
- Show the groups, the move table (issue -> group, new title, tracker, description) and the open questions in the review `.txt` file.

## Push rules learned (owner session 2026-10-13)

1. **Never call `/users/current.json`**: it returns the `api_key` in the output. Use the `author` or `assigned_to` of an issue, or `/users.json`. Never print a key.
2. **Read the parent first (Step 0).** When the owner names a parent id, GET it (read-only) before asking: subject, acceptance criteria, estimate, `allowed_statuses`. Ask only what is still missing.
3. **Size from the diff in the first draft** (Step 3b). No 108h draft that gets cut again.
4. **Push order:** create children first (a create call ignores `status_id`, so it starts as New; with task groups: Epic, Story, groups, then leaves), then PUT each status, then update the parents last (groups, Story, Epic), then read everything back.
5. **Redmine computes the parent** when it has children: start and due date, % done, total estimate and total spent. The review must say that the parent's own dates will be overwritten.
6. **Do not close what is not done.** UAT and production tasks stay open until the owner says they ran. Do not close a parent while a child is open: show the owner what stays open and ask once.
7. **No double counting** on a parent (see Spent above).
8. **Follow-up tasks:** a gap seen in code (no test for a client, a suspect timeout path) is offered as its own Bug / Spike / Task, not left only inside a report file.
9. A plain "confirm" after the review starts the push. "ok", "ok go", "create it" do not.
10. **Custom fields** (when enabled in `local.md`): closed lists may 403 on list API. Ask the owner for the exact label; do not try guessed labels one by one (L-21).
11. **Read the story back after editing children.** Redmine may fill the parent's own estimate. PUT `estimated_hours: 0` on the parent and read again when that happens.
12. **Use only the Redmine MCP named in `local.md`.** Never switch server on your own. Empty or missing name → leave mcp mode and finish as report-only.
13. **Re-cutting tasks after a push** (rename, split by endpoint) is a new review: show new tasks, renamed subjects, and every hour change, then wait for "confirm". Keep spent unchanged.

## Output format

**Write the review file first (owner rule 2026-10-13, L-22).** Before any Redmine write, and before a long answer in chat, save the whole report to a plain `.txt` file the owner can open and read: `.scratch/<feature>/redmine-breakdown-draft.txt` in the project (or the scratchpad folder when the project has no `.scratch`). It holds, in this order: the real flow as numbered steps (Step 2f), the review of the earlier draft, the style summary from Step 2d, the open questions for the owner, the record table with a "Size evidence" column (lines changed per task, Step 3b), the short descriptions, the impact notes (Step 2e), the follow-up gaps, and the push order. Say in the first lines that nothing was written to Redmine. In chat give a short summary and the file path, not the whole payload. Edit the same file after each owner reply; the owner reviews the file, then says "confirm".

**Two files, always (L-28).** `redmine-report.md` holds only what is sent to Redmine: Story text, one table (ID, Tracker, Subject, short Description, Priority, Status, Done %, Est. h, Spent h*, Start, Due), open questions, push order. `redmine-report-notes.md` holds everything else: evidence, flow, endpoint details, size evidence, tests found, risks, vendor scenarios. Nothing from the notes file is pushed.

One table, one row per record: `ID | Tracker | Parent | Subject | Description | Priority | Assignee | Status | Done % | Est. Hours | Spent Hours | Start Date | Due/Finish Date | Source` plus any custom-field columns from `local.md`. A required field that is empty is listed under "still open" with one question. Pushing (if any) is a separate companion step: review first, then the owner's confirm, then push. `Source` = commit hash or design-doc path, so every row traces to real evidence. State the total record count up top, e.g. "12 records: 1 Story + 8 Subtask + 2 Bug + 1 Task".

Report only. Never call a Redmine write endpoint (POST or PUT) from this skill. Creating the issues is a separate push that follows review, then confirm, then push (companion skill when installed): show every row and field for review, wait for the owner's plain "confirm", and only then push. An earlier "create it" or "ok" does not count as the confirm.

## Learn from problems (owner rule 2026-10-13)

When the owner says a result is not OK, or an issue shows up while working (push rejected, read-back differs, size or hours corrected, a fact was missing): fix the report first.
- Patch the matching rule in this file (change the old line, do not stack a second one). One rule, one line, with the reason.
- Optionally log one short lesson under Preferences in `local.md`. Same class twice: move the rule up into Step 0 or Push rules.
- Sweep records already in the report or in Redmine for the same defect, list the ids, ask once before fixing.
- Tell the owner in 3 lines: what was fixed, the cause, the new rule.

## Common Mistakes

| Mistake | Fix |
|---|---|
| Assuming Epic/Story/Task exists in Redmine | Check `/trackers.json` first, or ask |
| Story description has class/method names | Business language for story; technical detail only in subtasks |
| Building a new story when one is already assigned | Finish Setup (local.md), then ask Step 0 scope/parent every time |
| Calling Redmine without local.md / guessing MCP name | Step 0a: one-time setup with Mode + owner-picked MCP, or report-only |
| Re-asking full instance map every report | Read Setup summary in local.md; reset only on owner request |
| Pasting raw config diff (passwords, tokens) into a report | Summarize the change, redact the value |
| One combined "deploy" task | Split UAT and production; production gated on UAT |
| Writing rows from commit messages / git diff only | Read the current source, trace the flow, read tests (Step 2b) |
| Guessing the commit range | Tag → release-merge commit → ask, in that order |
| Force-classifying every commit into feature/bug/chore | Unclear commits go to "needs manual review" |
| Long, evenly formatted descriptions and 0.25h tasks that read as AI-written | Read the sibling project first (Step 2d); short titles, short or empty task descriptions, whole-hour tasks (L-22) |
| Changing a production flow and listing only build tasks | Start with a Review & Production Impact story (Step 2e) |
| Printing the whole report in chat | Write the `.txt` review file first, short summary in chat |
| Upload, register and save-result hidden inside one "Integration" story | Trace the real flow; one story per flow step, in flow order (Step 2f, L-23) |
| An easy task (constant, config, one line) with 2h or more | Size by lines changed and difficulty; the boss reads big hours on an easy task as slow work (Step 3b, L-23) |
