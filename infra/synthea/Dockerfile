# Dockerfile — Build Synthea from synthetichealth/synthea source
#
# Builds the official Synthea patient-data generator from GitHub source.
# Produces an image tagged synthea-local:latest for use by run-synthea.sh.
#
# Build:
#   docker build -t synthea-local:latest infra/synthea/
#
# Run (mirrors run-synthea.sh usage):
#   docker run --rm \
#     -e SYNTHEA_SIZE=10 \
#     -e JAVA_TOOL_OPTIONS="-Dexporter.csv.export=true" \
#     -v /absolute/path/to/output:/synthea/output \
#     synthea-local:latest

FROM eclipse-temurin:17-jdk-alpine AS builder

ARG SYNTHEA_VERSION=v4.0.0
ARG SYNTHEA_REPO=https://github.com/synthetichealth/synthea.git

RUN apk add --no-cache git

WORKDIR /build

RUN git clone --branch "${SYNTHEA_VERSION}" --depth 1 "${SYNTHEA_REPO}" synthea

WORKDIR /build/synthea

# Build the fat JAR; skip tests to keep image build time reasonable.
RUN ./gradlew uberJar -x test --no-daemon

# ─── Runtime stage ───────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine

WORKDIR /synthea

# Copy only the built JAR into the runtime image.
COPY --from=builder /build/synthea/build/libs/synthea-with-dependencies.jar ./synthea.jar

# Output directory — callers mount a host directory here.
RUN mkdir -p /synthea/output

# Default properties file can be overridden via volume mount.
COPY synthea.properties /synthea/synthea.properties

# Entrypoint script: honours SYNTHEA_SIZE and JAVA_TOOL_OPTIONS env vars.
COPY docker-entrypoint.sh /synthea/docker-entrypoint.sh
RUN chmod +x /synthea/docker-entrypoint.sh

ENTRYPOINT ["/synthea/docker-entrypoint.sh"]
