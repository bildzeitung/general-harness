#!/usr/bin/env bash
# smoke-test.sh — post-apply validation for the dolt server instance.
#
# Run from the terraform/ directory after `terraform apply` completes:
#   bash smoke-test.sh
#
# Requirements on the local machine:
#   - terraform (to read outputs)
#   - ssh / OpenSSH client
#   - mysql client (for the auth-rejection check)
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed
set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve connection details from Terraform outputs.
# ---------------------------------------------------------------------------
echo "==> Reading Terraform outputs..."
PUBLIC_IP=$(terraform output -raw instance_public_ip)
PEM="./oci_instance.pem"

if [[ ! -f "$PEM" ]]; then
  echo "ERROR: $PEM not found. Run terraform apply first."
  exit 1
fi

echo "    instance_public_ip = $PUBLIC_IP"
echo "    pem                = $PEM"
echo ""

# ---------------------------------------------------------------------------
# Check 1: Wait for cloud-init to finish (up to 5 minutes).
# cloud-init runs the dolt installer and starts the service; it must
# complete before the service checks below are meaningful.
# ---------------------------------------------------------------------------
echo "==> [1/3] Waiting for cloud-init to finish (up to 5 min)..."
ssh -i "$PEM" \
    -o StrictHostKeyChecking=no \
    -o ConnectTimeout=30 \
    opc@"$PUBLIC_IP" \
    "sudo cloud-init status --wait"
echo "    cloud-init: done"
echo ""

# ---------------------------------------------------------------------------
# Check 2: Verify dolt-server service is active.
# ---------------------------------------------------------------------------
echo "==> [2/3] Checking dolt-server service status..."
SERVICE_STATUS=$(
  ssh -i "$PEM" \
      -o StrictHostKeyChecking=no \
      -o ConnectTimeout=30 \
      opc@"$PUBLIC_IP" \
      "systemctl is-active dolt-server"
)
if [[ "$SERVICE_STATUS" == "active" ]]; then
  echo "    PASS: dolt-server is active"
else
  echo "    FAIL: dolt-server status is '$SERVICE_STATUS' (expected 'active')"
  exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# Check 3: Verify that unauthenticated MySQL connections are rejected.
# dolt-server requires a password; an anonymous connection must be refused
# with an "Access denied" error.
# ---------------------------------------------------------------------------
echo "==> [3/3] Checking that unauthenticated MySQL access is rejected..."
MYSQL_OUTPUT=$(
  mysql -h "$PUBLIC_IP" -P 3306 -u root \
        --connect-timeout=10 2>&1 \
  || true
)
if echo "$MYSQL_OUTPUT" | grep -qi "Access denied"; then
  echo "    PASS: unauthenticated access rejected (Access denied)"
else
  echo "    FAIL: expected 'Access denied' but got:"
  echo "    $MYSQL_OUTPUT"
  exit 1
fi
echo ""

# ---------------------------------------------------------------------------
# All checks passed.
# ---------------------------------------------------------------------------
echo "All checks passed."
