#!/bin/bash
set -euo pipefail

# Ensure dolt tracks 'trunk' on the remote, not 'main' (which bootstrap resets to)
ensure_dolt_trunk() {
    local repo_state=".beads/embeddeddolt/harness/.dolt/repo_state.json"
    [[ -f "$repo_state" ]] || return 0
    grep -q '"head": "refs/heads/main"' "$repo_state" || return 0
    echo "==> Fixing dolt branch tracking (main → trunk)..."
    bd branch trunk 2>/dev/null || true
    python3 -c "
import json
with open('$repo_state') as f:
    s = json.load(f)
s['head'] = 'refs/heads/trunk'
s['branches'] = {'trunk': {'head': 'refs/heads/trunk', 'remote': 'origin', 'merge': 'refs/heads/trunk'}}
with open('$repo_state', 'w') as f:
    json.dump(s, f, indent=2)
"
}
ensure_dolt_trunk

# Pull latest tickets from remote before starting work
echo "==> Pulling beads from remote..."
bd dolt pull

echo "==> Pulling code from remote..."
git pull --rebase

echo ""
echo "==> Ready tickets:"
bd ready
