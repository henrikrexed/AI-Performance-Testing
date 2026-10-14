# syntax=docker/dockerfile:1
# -----------------------------------------------------------------------------
# AI-Performance-Testing — workload-model engine (SCOPE stage)
#
# A minimal, multi-arch image wrapping the engine CLI (engine/cli.py — the maintained
# package with the `guided` 4-step driver). The engine is backend- and tool-agnostic:
# it turns a neutral telemetry extract (JSON) into a G0-gated workload-model.json +
# scenario-proposal.md. It never talks to a backend or a load tool.
#
# Built + pushed by .github/workflows/docker.yml (the single GHCR push path).
#
# Run:
#   docker run --rm -v "$PWD":/work ghcr.io/henrikrexed/ai-performance-testing:latest \
#     --extract /work/extract.json --out /work/out --mode agentic
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
# Engine source: the maintained `engine/` package (deterministic core + cli.py with the
# `guided` 4-step driver; schema.json lives here). Mount your telemetry extract at /work
# and pass --extract; the engine is agnostic and ships no backend/default fixture.
COPY engine/ ./engine/
ENV PYTHONPATH=/app/engine

# Run as a non-root user; /work is the conventional I/O mount point.
RUN useradd --uid 10001 --create-home --shell /usr/sbin/nologin engine \
    && mkdir /work && chown engine:engine /work
USER engine
WORKDIR /work

ENTRYPOINT ["python", "/app/engine/cli.py"]
CMD ["--help"]
