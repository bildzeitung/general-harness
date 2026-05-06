#!/usr/bin/env bash
# run-synthea.sh — Wrapper for Synthea synthetic patient data generation via Docker.
#
# Usage:
#   ./run-synthea.sh <PATIENT_COUNT> <OUTPUT_DIR>
#
# Arguments:
#   PATIENT_COUNT  Number of synthetic patients to generate (e.g. 10)
#   OUTPUT_DIR     Directory where Synthea output will be written (e.g. infra/synthea/output)
#
# Output: OUTPUT_DIR/csv/patients.csv only (controlled via synthea.properties).
# FHIR R4 JSON bundles are also written to OUTPUT_DIR/fhir/.
# Exits with Docker's exit code.

set -euo pipefail

PATIENT_COUNT="${1:?PATIENT_COUNT argument is required}"
OUTPUT_DIR="${2:?OUTPUT_DIR argument is required}"

# Resolve OUTPUT_DIR and the properties file to absolute paths before mounting into Docker.
mkdir -p "$OUTPUT_DIR"
ABS_OUTPUT_DIR="$(realpath "$OUTPUT_DIR")"

# Locate synthea.properties relative to this script so it can be mounted into the
# container. This ensures CSV export is enabled even when using a pre-built image
# whose baked-in properties file has exporter.csv.export=false.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROPERTIES_FILE="${SCRIPT_DIR}/synthea.properties"

echo "Running Synthea via Docker..."
echo "  Patient count : $PATIENT_COUNT"
echo "  Output dir    : $ABS_OUTPUT_DIR"
echo "  Properties    : $PROPERTIES_FILE"

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -e SYNTHEA_SIZE="$PATIENT_COUNT" \
  -v "${PROPERTIES_FILE}:/synthea/synthea.properties:ro" \
  -v "${ABS_OUTPUT_DIR}:/synthea/output" \
  synthea-local:latest

EXIT_CODE=$?

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Synthea completed successfully."
  echo "Patient CSV written to: ${ABS_OUTPUT_DIR}/csv/patients.csv"
  echo "FHIR bundles written to: ${ABS_OUTPUT_DIR}/fhir/"
else
  echo "Synthea exited with code $EXIT_CODE." >&2
fi

exit "$EXIT_CODE"
