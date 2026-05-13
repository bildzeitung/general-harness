---
description: Create a sequentially-numbered epic template in the current project's epics/ directory
---

# epic

Create a new epic template file, ready to edit.

## Arguments

Optionally takes a short slug describing the epic (e.g., `/epic user-auth`).
If not provided, ask the user: **"What's a short slug for this epic? (e.g., `user-auth`)"**

## Step 1 — Find the epics directory

Walk up from the current working directory looking for an `epics/` subdirectory.
Use the first one found. If none is found after reaching the filesystem root, ask the user:
**"I couldn't find an epics/ directory. Which project should I create the epic in?"**
and list the directories visible from the cwd.

## Step 2 — Determine the next sequence number

```bash
ls <epics-dir>/*.md 2>/dev/null | grep -oP '^\d+' | sort -n | tail -1
```

If no files exist yet, start at `01`. Otherwise add 1 to the highest number, zero-padded to two digits (e.g., `07`).

## Step 3 — Normalise the slug

Lowercase the slug, replace spaces with hyphens, strip characters that aren't letters, digits, or hyphens.
Example: `"User Auth Flow"` → `user-auth-flow`.

## Step 4 — Write the template

Create `<epics-dir>/<NN>-<slug>.md` with this content (replace `<NN>` and `<slug>` with the actual values; leave the H1 title as-is for the user to fill in):

```markdown
# <Title>

## Goal

<!-- What is this epic trying to achieve? One or two sentences. -->

## Constraints

<!-- Non-negotiable rules and boundaries. Delete if none. -->

## Design

<!-- High-level approach or architecture notes. Delete if not needed yet. -->

## Dependencies

<!-- Other epics or external factors that must be resolved first. Delete if none. -->

## Done criteria

<!-- Bullet list of verifiable conditions that prove this epic is complete. -->
-
```

## Step 5 — Report

Output the full path of the created file, e.g.:

> Created **epics/07-user-auth.md** — edit it, then invoke the `epic-filer` agent (or run `/file-epic <path>`) to file it with beads.
