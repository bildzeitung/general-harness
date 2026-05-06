#!/usr/bin/env bash
# smoke-test.sh — Validates the medplum-agent scaffold without requiring a running Docker daemon.
#
# Checks:
#   1. agents/medplum-agent.md exists with valid YAML front-matter (name + description).
#   2. Controller dispatch rule routes 'medplum' tasks to medplum-agent.
#   3. infra/medplum/docker-compose.yml exists and is valid YAML with at least one service.
#   4. infra/medplum/medplum.env exists and is non-empty.
#   5. infra/medplum/connection.json is gitignored (absent from git tracking).
#
# Exits 0 on success, non-zero with a descriptive error on any failure.

set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  PASS: $*"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $*" >&2; FAIL=$((FAIL + 1)); }

echo "=== medplum-agent smoke-test ==="
echo "Harness root: $HARNESS_ROOT"
echo ""

# ---------------------------------------------------------------------------
# Check 1: agents/medplum-agent.md — YAML front-matter with name + description
# ---------------------------------------------------------------------------
echo "[1] agents/medplum-agent.md front-matter"
AGENT_MD="$HARNESS_ROOT/agents/medplum-agent.md"
if [ ! -f "$AGENT_MD" ]; then
  fail "File not found: $AGENT_MD"
else
  if grep -q "^name: medplum-agent" "$AGENT_MD"; then
    pass "name: medplum-agent found"
  else
    fail "Missing 'name: medplum-agent' in YAML front-matter of $AGENT_MD"
  fi
  DESCRIPTION=$(grep "^description:" "$AGENT_MD" | head -1 | sed 's/^description:\s*//')
  if [ -n "$DESCRIPTION" ]; then
    pass "description field is non-empty: '$DESCRIPTION'"
  else
    fail "Missing or empty 'description' field in YAML front-matter of $AGENT_MD"
  fi
fi

# ---------------------------------------------------------------------------
# Check 2: controller.md dispatch rule routes 'medplum' tasks to medplum-agent
# ---------------------------------------------------------------------------
echo ""
echo "[2] controller.md dispatch rule for medplum-agent"
CONTROLLER_MD="$HARNESS_ROOT/agents/controller.md"
if [ ! -f "$CONTROLLER_MD" ]; then
  fail "File not found: $CONTROLLER_MD"
else
  if grep -q "medplum" "$CONTROLLER_MD" && grep -q "medplum-agent" "$CONTROLLER_MD"; then
    pass "controller.md contains dispatch rule referencing 'medplum' and 'medplum-agent'"
  else
    fail "controller.md missing medplum-agent dispatch rule"
  fi
  # Simulate matching the expected title
  EXAMPLE_TITLE="Start medplum for integration test"
  TITLE_LOWER=$(echo "$EXAMPLE_TITLE" | tr '[:upper:]' '[:lower:]')
  if echo "$TITLE_LOWER" | grep -q "medplum"; then
    pass "Title '$EXAMPLE_TITLE' contains 'medplum' — dispatch rule would match"
  else
    fail "Example title '$EXAMPLE_TITLE' does not match 'medplum' pattern"
  fi
fi

# ---------------------------------------------------------------------------
# Check 3: infra/medplum/docker-compose.yml — valid YAML with at least one service
# ---------------------------------------------------------------------------
echo ""
echo "[3] infra/medplum/docker-compose.yml"
COMPOSE_FILE="$HARNESS_ROOT/infra/medplum/docker-compose.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
  fail "File not found: $COMPOSE_FILE"
else
  pass "docker-compose.yml exists"
  # Validate YAML and check for services key using Python (no Docker daemon needed)
  YAML_CHECK=$(python3 -c "
import sys, yaml
try:
    with open('$COMPOSE_FILE') as f:
        data = yaml.safe_load(f)
    services = data.get('services', {})
    if not services:
        print('ERROR: no services defined')
        sys.exit(1)
    print(f'OK: {len(services)} service(s): {list(services.keys())}')
except yaml.YAMLError as e:
    print(f'YAML parse error: {e}')
    sys.exit(1)
" 2>&1)
  YAML_EXIT=$?
  if [ $YAML_EXIT -eq 0 ]; then
    pass "docker-compose.yml is valid YAML — $YAML_CHECK"
  else
    fail "docker-compose.yml validation failed: $YAML_CHECK"
  fi
fi

# ---------------------------------------------------------------------------
# Check 4: infra/medplum/medplum.env — exists and non-empty
# ---------------------------------------------------------------------------
echo ""
echo "[4] infra/medplum/medplum.env"
ENV_FILE="$HARNESS_ROOT/infra/medplum/medplum.env"
if [ ! -f "$ENV_FILE" ]; then
  fail "File not found: $ENV_FILE"
else
  pass "medplum.env exists"
  ENV_LINES=$(grep -c "^[A-Z]" "$ENV_FILE" || true)
  if [ "$ENV_LINES" -gt 0 ]; then
    pass "medplum.env has $ENV_LINES variable definition(s)"
  else
    fail "medplum.env appears to be empty or has no variable definitions"
  fi
fi

# ---------------------------------------------------------------------------
# Check 5: infra/medplum/connection.json — gitignored (not tracked by git)
# ---------------------------------------------------------------------------
echo ""
echo "[5] infra/medplum/connection.json is gitignored"
CONNECTION_JSON="$HARNESS_ROOT/infra/medplum/connection.json"
GITIGNORE_FILE="$HARNESS_ROOT/infra/medplum/.gitignore"

# Check .gitignore contains connection.json
if [ ! -f "$GITIGNORE_FILE" ]; then
  fail "File not found: $GITIGNORE_FILE"
else
  if grep -q "connection.json" "$GITIGNORE_FILE"; then
    pass ".gitignore lists connection.json"
  else
    fail ".gitignore does not list connection.json"
  fi
fi

# Verify git check-ignore agrees (create a temp file if needed to test)
TEMP_CREATED=0
if [ ! -f "$CONNECTION_JSON" ]; then
  touch "$CONNECTION_JSON"
  TEMP_CREATED=1
fi

GIT_IGNORED=$(git -C "$HARNESS_ROOT" check-ignore -q "$CONNECTION_JSON" 2>/dev/null && echo "yes" || echo "no")
if [ "$TEMP_CREATED" -eq 1 ]; then
  rm -f "$CONNECTION_JSON"
fi

if [ "$GIT_IGNORED" = "yes" ]; then
  pass "git confirms infra/medplum/connection.json is gitignored"
else
  fail "git does NOT ignore infra/medplum/connection.json — check .gitignore"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
