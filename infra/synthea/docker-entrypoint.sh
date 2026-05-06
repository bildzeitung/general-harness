#!/usr/bin/env bash
# docker-entrypoint.sh — Run Synthea inside the synthea-local container.
#
# Environment variables:
#   SYNTHEA_SIZE          Number of synthetic patients to generate (default: 10)
#   JAVA_TOOL_OPTIONS     Extra JVM options (e.g. -Dexporter.csv.export=true)
#
# Output is written to /synthea/output (mount a host directory there).

set -euo pipefail

SYNTHEA_SIZE="${SYNTHEA_SIZE:-10}"

echo "Starting Synthea..."
echo "  Patient count : ${SYNTHEA_SIZE}"
echo "  JVM options   : ${JAVA_TOOL_OPTIONS:-<none>}"

exec java \
  ${JAVA_TOOL_OPTIONS:-} \
  -jar /synthea/synthea.jar \
  -c /synthea/synthea.properties \
  --exporter.baseDirectory=/synthea/output \
  -p "${SYNTHEA_SIZE}"
