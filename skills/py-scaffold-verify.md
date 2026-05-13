---
description: Run init.sh and nox to verify a freshly scaffolded Python project is clean
---

# py-scaffold-verify

Boot the project virtualenv and confirm all quality gates pass.

## Steps

1. Run `bash init.sh` — must exit 0
2. Run `./venv/bin/nox` — must exit 0; all three sessions (`tests`, `ruff`, `typecheck`) must pass

## On failure

Report the exact error output. Do **not** attempt to fix anything — that is the
caller's responsibility.

## On success

Confirm: "All nox sessions passed."
