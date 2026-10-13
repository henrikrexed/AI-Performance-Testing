# syntax=docker/dockerfile:1
# -----------------------------------------------------------------------------
# AI-Performance-Testing — workload-model engine (SCOPE stage)
#
# A minimal, multi-arch image wrapping the engine CLI
# (skills/workload-model/scripts/cli.py). The engine is backend- and tool-agnostic:
# it turns a neutral telemetry extract (JSON) into a G0-gated workload-model.json +
# scenario-proposal.md. It never talks to a backend or a load tool.
#
# Built + pushed by .github/workflows/docker.yml (the single GHCR push path).
#
# Run:
#   docker run --rm -v "$PWD":/work ghcr.io/henrikrexed/ai-performance-testing:latest \
#     --extract /work/extract.json --out /work/out            # commerce (default)
#   docker run --rm ghcr.io/henrikrexed/ai-performance-testing:latest --help
# -----------------------------------------------------------------------------
FROM python:3.12-slim

LABEL org.opencontainers.image.title="AI-Performance-Testing workload-model engine" \
      org.opencontainers.image.description="Observability-driven workload modeling (SCOPE): neutral telemetry extract -> G0-gated workload-model.json + scenario-proposal.md" \
      org.opencontainers.image.source="https://github.com/henrikrexed/AI-Performance-Testing" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="IsItObservable / Henrik Rexed"

# jsonschema is the engine's only runtime dependency (G0 schema validation).
RUN pip install --no-cache-dir "jsonschema>=4,<5"

WORKDIR /app
# Engine source (scripts/ = the deterministic core + cli.py; schema.json lives here) and
# the bundled synthetic default fixture (resolved by cli.py relative to scripts/..).
COPY skills/workload-model/scripts/ ./scripts/
COPY skills/workload-model/fixtures/example_extract.json ./fixtures/example_extract.json
COPY skills/workload-model/fixtures/example_agentic_extract.json ./fixtures/example_agentic_extract.json
ENV PYTHONPATH=/app/scripts

# Run as a non-root user; /work is the conventional I/O mount point.
RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin engine \
    && mkdir /work && chown engine:engine /work
USER engine
WORKDIR /work

ENTRYPOINT ["python", "/app/scripts/cli.py"]
CMD ["--help"]
