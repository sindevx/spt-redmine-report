#!/usr/bin/env python3
"""Check a redmine-report.md payload table before any Redmine push.

Usage: python3 check_report.py <redmine-report.md> [--story-hours 20]
Exit 0 = no errors (warnings may print). Exit 1 = at least one error.
Table columns: ID | Tracker | Subject | Description | Priority | Status | Done % | Est. h | Spent h | Start | Due
"""
import datetime
import re
import sys

ACTION_WORDS = {"get", "analyse", "design", "integrate", "implement", "serve", "map", "write", "build",
                "deploy", "test", "fix", "create", "define", "review", "document", "add", "update", "remove"}
errors, warnings = [], []


def number(text):
    match = re.search(r"\d+(\.\d+)?", text)
    return float(match.group()) if match else None


def read_date(text):
    try:
        return datetime.date.fromisoformat(text.strip().strip("*"))
    except ValueError:
        return None


def main():
    path = sys.argv[1]
    story_hours = float(sys.argv[sys.argv.index("--story-hours") + 1]) if "--story-hours" in sys.argv else None
    rows = []
    for line in open(path, encoding="utf-8"):
        if re.match(r"\|\s*R\d+\s*\|", line):
            rows.append([cell.strip() for cell in line.strip().strip("|").split("|")])
    if not rows:
        print("ERROR: no task rows found (rows must start with | R<number> |)")
        sys.exit(1)

    estimate_total = 0.0
    for row in rows:
        if len(row) != 11:
            errors.append(f"{row[0]}: expected 11 columns, found {len(row)}")
            continue
        task_id, tracker, subject, description, priority, status, done, estimate, spent, start, due = row
        estimate_value, spent_value = number(estimate), number(spent)
        if estimate_value is None:
            errors.append(f"{task_id}: estimate is missing")
            continue
        estimate_total += estimate_value

        if re.search(r"`|\.java|\.py\b", subject + " " + description):
            errors.append(f"{task_id}: code name or file path in subject/description (business words only)")
        if re.search(r"\b(?=[0-9a-f]*\d)[0-9a-f]{7,40}\b", subject + " " + description):
            errors.append(f"{task_id}: commit hash in subject/description")
        if re.search(r"\b[A-Z][a-z]+[A-Z][a-zA-Z]+\b", subject + " " + description):
            warnings.append(f"{task_id}: CamelCase word (class name?) in subject/description")
        if subject.split()[0].lower().strip(":") not in ACTION_WORDS:
            warnings.append(f"{task_id}: subject does not start with an action verb")
        if len(subject) > 90:
            warnings.append(f"{task_id}: subject is {len(subject)} characters (aim for 90 or less)")
        if not description:
            errors.append(f"{task_id}: description is empty")

        if status == "Closed":
            if done != "100":
                errors.append(f"{task_id}: Closed but done % is {done}")
            if spent_value is None:
                errors.append(f"{task_id}: Closed but spent hours missing")
            elif not 0.5 <= spent_value / estimate_value <= 1.5:
                errors.append(f"{task_id}: spent/estimate = {spent_value / estimate_value:.2f} (allowed 0.5 to 1.5)")
            start_date, due_date = read_date(start), read_date(due)
            if not start_date or not due_date:
                errors.append(f"{task_id}: Closed but start/due is not a date")
            else:
                if start_date > due_date:
                    errors.append(f"{task_id}: start {start} is after due {due}")
                for name, day in (("start", start_date), ("due", due_date)):
                    if day.weekday() >= 5:
                        errors.append(f"{task_id}: {name} {day} is a weekend")
                if start_date == due_date and estimate_value > 1:
                    warnings.append(f"{task_id}: start and due are the same day but estimate is {estimate_value}h")
        elif spent_value not in (None, 0):
            errors.append(f"{task_id}: status {status} but spent hours {spent}")
        if not description.startswith("Plan:") and status != "Closed":
            warnings.append(f"{task_id}: open task description should start with 'Plan:'")

    if story_hours is not None and abs(estimate_total - story_hours) > 0.01:
        errors.append(f"estimates add up to {estimate_total}h, story is {story_hours}h")
    print(f"rows: {len(rows)}  estimate total: {estimate_total}h")
    for message in warnings:
        print("WARN :", message)
    for message in errors:
        print("ERROR:", message)
    print("RESULT:", "FAIL" if errors else "PASS")
    sys.exit(1 if errors else 0)


main()
