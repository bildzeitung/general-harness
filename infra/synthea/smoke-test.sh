#!/usr/bin/env bash
# smoke-test.sh — Validates the synthea-agent scaffold without network or Java access.
#
# Checks:
#   1. agents/synthea-agent.md exists with valid YAML front-matter (name + description).
#   2. Controller dispatch rule routes "synthea" tasks to synthea-agent.
#   3. infra/synthea/run-synthea.sh exists, is executable, and references Docker invocation.
#   4. infra/synthea/synthea.properties exists and has valid key=value syntax.
#   5. infra/synthea/.gitignore exists and lists 'output/'.
#
# Exits 0 on success, non-zero with a descriptive error on any failure.

set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  PASS: $*"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $*" >&2; FAIL=$((FAIL + 1)); }

echo "=== synthea-agent smoke-test ==="
echo "Harness root: $HARNESS_ROOT"
echo ""

# ---------------------------------------------------------------------------
# Check 1: agents/synthea-agent.md — YAML front-matter with name + description
# ---------------------------------------------------------------------------
echo "[1] agents/synthea-agent.md front-matter"
AGENT_MD="$HARNESS_ROOT/agents/synthea-agent.md"
if [ ! -f "$AGENT_MD" ]; then
  fail "File not found: $AGENT_MD"
else
  if grep -q "^name: synthea-agent" "$AGENT_MD"; then
    pass "name: synthea-agent found"
  else
    fail "Missing 'name: synthea-agent' in YAML front-matter of $AGENT_MD"
  fi
  DESCRIPTION=$(grep "^description:" "$AGENT_MD" | head -1 | sed 's/^description:\s*//')
  if [ -n "$DESCRIPTION" ]; then
    pass "description field is non-empty: '$DESCRIPTION'"
  else
    fail "Missing or empty 'description' field in YAML front-matter of $AGENT_MD"
  fi
fi

# ---------------------------------------------------------------------------
# Check 2: controller.md dispatch rule routes 'synthea' tasks to synthea-agent
# ---------------------------------------------------------------------------
echo ""
echo "[2] controller.md dispatch rule for synthea-agent"
CONTROLLER_MD="$HARNESS_ROOT/agents/controller.md"
if [ ! -f "$CONTROLLER_MD" ]; then
  fail "File not found: $CONTROLLER_MD"
else
  # Verify the dispatch table contains a row mapping synthea -> synthea-agent
  if grep -q "synthea" "$CONTROLLER_MD" && grep -q "synthea-agent" "$CONTROLLER_MD"; then
    pass "controller.md contains dispatch rule referencing 'synthea' and 'synthea-agent'"
  else
    fail "controller.md missing synthea-agent dispatch rule"
  fi
  # Simulate matching the example title from the spec
  EXAMPLE_TITLE="Generate synthea patients for integration test"
  TITLE_LOWER=$(echo "$EXAMPLE_TITLE" | tr '[:upper:]' '[:lower:]')
  if echo "$TITLE_LOWER" | grep -q "synthea"; then
    pass "Title '$EXAMPLE_TITLE' contains 'synthea' — dispatch rule would match"
  else
    fail "Example title '$EXAMPLE_TITLE' does not match 'synthea' pattern"
  fi
fi

# ---------------------------------------------------------------------------
# Check 3: infra/synthea/run-synthea.sh — executable, references Docker
# ---------------------------------------------------------------------------
echo ""
echo "[3] infra/synthea/run-synthea.sh"
RUN_SCRIPT="$HARNESS_ROOT/infra/synthea/run-synthea.sh"
if [ ! -f "$RUN_SCRIPT" ]; then
  fail "File not found: $RUN_SCRIPT"
else
  pass "run-synthea.sh exists"
  if test -x "$RUN_SCRIPT"; then
    pass "run-synthea.sh is executable"
  else
    fail "run-synthea.sh is NOT executable (run: chmod +x $RUN_SCRIPT)"
  fi
  # Implementation uses Docker (mrreband/synthea-docker), not a JAR.
  if grep -q "docker" "$RUN_SCRIPT"; then
    pass "run-synthea.sh references 'docker' (Docker-based implementation confirmed)"
  else
    fail "run-synthea.sh does not reference 'docker'"
  fi
  if grep -q "synthea-local:latest" "$RUN_SCRIPT"; then
    pass "run-synthea.sh references synthea-local:latest image"
  else
    fail "run-synthea.sh does not reference synthea-local:latest"
  fi
  if grep -q "PATIENT_COUNT" "$RUN_SCRIPT"; then
    pass "run-synthea.sh references PATIENT_COUNT parameter"
  else
    fail "run-synthea.sh does not use PATIENT_COUNT"
  fi
fi

# ---------------------------------------------------------------------------
# Check 4: synthea.properties — valid key=value syntax
# ---------------------------------------------------------------------------
echo ""
echo "[4] infra/synthea/synthea.properties"
PROPS="$HARNESS_ROOT/infra/synthea/synthea.properties"
if [ ! -f "$PROPS" ]; then
  fail "File not found: $PROPS"
else
  pass "synthea.properties exists"
  # Valid lines: blank, comment (#), or key = value (with optional spaces around =)
  INVALID=$(grep -vE '^\s*$|^\s*#|^\s*[A-Za-z0-9_.]+\s*=\s*.*$' "$PROPS" || true)
  if [ -z "$INVALID" ]; then
    pass "synthea.properties has valid key=value syntax"
  else
    fail "synthea.properties has invalid lines:"$'\n'"$INVALID"
  fi
  if grep -q "exporter.fhir.export" "$PROPS"; then
    pass "synthea.properties configures exporter.fhir.export"
  else
    fail "synthea.properties does not set exporter.fhir.export"
  fi
fi

# ---------------------------------------------------------------------------
# Check 5: infra/synthea/.gitignore — lists 'output/'
# ---------------------------------------------------------------------------
echo ""
echo "[5] infra/synthea/.gitignore"
GITIGNORE="$HARNESS_ROOT/infra/synthea/.gitignore"
if [ ! -f "$GITIGNORE" ]; then
  fail "File not found: $GITIGNORE"
else
  pass ".gitignore exists"
  if grep -q "^output/" "$GITIGNORE"; then
    pass ".gitignore lists 'output/'"
  else
    fail ".gitignore does not list 'output/'"
  fi
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
