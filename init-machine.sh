#!/bin/bash
set -euo pipefail

check_dep() {
    if ! command -v "$1" &>/dev/null; then
        echo "ERROR: '$1' not found. $2" >&2
        exit 1
    fi
}

# --- Checks ---
check_dep git       "Install git."
check_dep bd        "Install beads: https://github.com/gastownhall/beads"
check_dep gh        "Install gh: https://cli.github.com"
check_dep direnv    "Install direnv: https://direnv.net"
check_dep terraform "Install terraform: https://developer.hashicorp.com/terraform/install"

echo "==> Checking GitHub SSH auth..."
ssh_output=$(ssh -T git@github.com 2>&1 || true)
if ! echo "$ssh_output" | grep -q "Hi "; then
    echo "ERROR: GitHub SSH auth failed. Run: ssh-keygen && gh ssh-key add ~/.ssh/id_ed25519.pub" >&2
    exit 1
fi

# --- Environment ---
if [[ ! -f ".envrc" ]]; then
    echo "ERROR: .envrc not found. Create it with BEADS_DOLT_SERVER_HOST, BEADS_DOLT_SERVER_PORT, BEADS_DOLT_USER, and BEADS_DOLT_PASSWORD set." >&2
    exit 1
fi

echo "==> Loading environment..."
direnv allow .
eval "$(direnv export bash)"

if [[ -z "${BEADS_DOLT_SERVER_HOST:-}" ]]; then
    echo "ERROR: BEADS_DOLT_SERVER_HOST not set after loading .envrc." >&2
    exit 1
fi

# --- Beads init if needed ---
if [[ ! -d ".beads/dolt" ]]; then
    echo "==> Initializing beads..."
    bd init --server --external --non-interactive --skip-hooks --skip-agents
fi

echo "==> Pulling tickets from remote..."
bd dolt pull

echo ""
echo "Machine initialized. Run ./session-start.sh at the start of each session."
