#!/bin/bash
set -euo pipefail

BEADS_REMOTE="git+ssh://git@github.com/bildzeitung/intrahealth-beads.git"

check_dep() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: '$1' not found. $2" >&2
        exit 1
    fi
}

# --- Checks ---
check_dep git   "Install git."
check_dep bd    "Install beads: https://github.com/gastownhall/beads"
check_dep gh    "Install gh: https://cli.github.com"

echo "==> Checking GitHub SSH auth..."
ssh_output=$(ssh -T git@github.com 2>&1 || true)
if ! echo "$ssh_output" | grep -q "Hi "; then
    echo "ERROR: GitHub SSH auth failed. Run: ssh-keygen && gh ssh-key add ~/.ssh/id_ed25519.pub" >&2
    exit 1
fi

chmod 700 .beads

# --- Beads init if needed ---
if [[ ! -d ".beads/embeddeddolt" ]]; then
    echo "==> Initializing beads..."
    bd init --non-interactive --skip-hooks --skip-agents
fi

# Ensure dolt tracks 'trunk' on the remote, not 'main' (which init/bootstrap resets to)
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

echo "==> Pulling tickets from remote..."
bd dolt pull

echo ""
echo "Machine initialized. Run ./session-start.sh at the start of each session."
