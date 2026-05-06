#!/usr/bin/env bash
# build-synthea-image.sh — Build the synthea-local Docker image from source.
#
# Usage:
#   ./infra/synthea/build-synthea-image.sh [SYNTHEA_VERSION]
#
# Arguments:
#   SYNTHEA_VERSION   Git tag to build from (default: v4.0.0)
#
# The resulting image is tagged synthea-local:latest and can be used
# immediately by infra/synthea/run-synthea.sh.
#
# Exits with Docker's exit code.

set -euo pipefail

HARNESS_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SYNTHEA_VERSION="${1:-v4.0.0}"
IMAGE_TAG="synthea-local:latest"

echo "Building Synthea Docker image..."
echo "  Source version : ${SYNTHEA_VERSION}"
echo "  Image tag      : ${IMAGE_TAG}"
echo "  Dockerfile     : ${HARNESS_ROOT}/infra/synthea/Dockerfile"
echo ""

docker build \
  --build-arg "SYNTHEA_VERSION=${SYNTHEA_VERSION}" \
  -t "${IMAGE_TAG}" \
  "${HARNESS_ROOT}/infra/synthea/"

echo ""
echo "Build complete. Image tagged as: ${IMAGE_TAG}"
