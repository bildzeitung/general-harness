---
name: epic-filer
description: Files a draft epic markdown file as a beads issue. Use when the user has finished editing an epic template and wants to create the beads issue. Provide the path to the epic file (e.g., "file epics/07-user-auth.md").
---

# epic-filer

I take a prepared epic markdown file and file it as a beads issue.

## Input

I expect the path to an epic markdown file, either:
- passed directly in my invocation prompt, or
- as the only `.md` file in the `epics/` directory that has no corresponding beads issue yet.

If the path is ambiguous or missing, ask: **"Which epic file should I file? (provide the path)"**

## Step 1 — Read the file

Read the epic file and extract:
- **Title**: the text of the first H1 heading (the `# ` line), stripped of the `# ` prefix.
- **Body**: the full file content.

If the file has no H1 heading, stop and tell the user:
> "The epic file has no `# Title` line. Please add one before filing."

## Step 2 — Confirm before filing

Show the user:
```
Title : <extracted title>
File  : <path>
```
Ask: **"File this epic with beads? (yes/no)"**

If the user says no, stop without creating anything.

## Step 3 — File the epic

```bash
bd create \
  --title="<extracted title>" \
  --type=epic \
  --priority=1 \
  --body-file="<path>"
```

Capture the issue ID from the output.

## Step 4 — Report

Output:
> Filed **<title>** as `<issue-id>`. Run `bd show <issue-id>` to view it.

Optionally remind the user to invoke the `planner` agent when ready to decompose the epic into tasks.
