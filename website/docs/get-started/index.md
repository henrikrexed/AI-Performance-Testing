---
id: index
title: Get started
sidebar_label: Overview & quickstart
description: Install the released engine (binary or Docker), the skills, or run from source — then walk the loop, the no-backend example first and the full live loop when you're ready.
slug: /get-started
---

# Get started

First get the tool, then walk the loop. Start with the no-backend example to see what each
stage produces, then run the full live loop against your own tenant when you're ready.

For what you need before the live loop — tokens, scopes, and agent tooling — see
[Requirements](./requirements.md). To install the skills into your coding agent, see
[Installing the skills](./skills-install.md). For every engine install path (per-platform
binary, Docker, Kubernetes, source), see [The engine](./engine.md).

## Install

Pick the path that fits. The fastest way to run SCOPE is the **released engine** — a
standalone binary or a container, no Python toolchain required. To drive the whole loop
from your coding agent, install the **skills**. To hack on the code, clone the **source**.

### Fastest — the released engine (binary or Docker)

The engine ships as a standalone `workload-engine` binary and a multi-arch container
(amd64 + arm64) on every release. The current pinned tag is
[**`v0.1.0`**](https://github.com/henrikrexed/AI-Performance-Testing/releases/tag/v0.1.0);
use [`latest`](https://github.com/henrikrexed/AI-Performance-Testing/releases/latest) to
always track the newest.

**Docker:**

```sh
docker pull ghcr.io/henrikrexed/ai-performance-testing:0.1.0   # or :latest
```

:::note
The **image** tag is `0.1.0` (no `v`); the GitHub **release** that ships the binaries is
tagged `v0.1.0`.
:::

**Binary** — download the one for your platform from the
[latest release](https://github.com/henrikrexed/AI-Performance-Testing/releases/latest).
Each binary ships a CycloneDX SBOM (`<binary>.cyclonedx.json`) next to it:

```sh
VERSION=v0.1.0
curl -fsSL -o workload-engine \
  "https://github.com/henrikrexed/AI-Performance-Testing/releases/download/${VERSION}/workload-engine-linux-amd64"
chmod +x workload-engine && ./workload-engine --help
```

macOS (Apple Silicon), Windows, and a one-shot Kubernetes `Job` are all in
[The engine](./engine.md) §1.

### Install the skills into your coding agent

One command fetches the repo and installs the skills into your agent (default
`~/.claude/skills`), verifying each one:

```sh
curl -fsSL https://raw.githubusercontent.com/henrikrexed/AI-Performance-Testing/main/install.sh | sh
```

It prints the exact next command — the first prompt of the guided loop. Per-agent paths
(opencode, Cursor, cross-client) are in [Installing the skills](./skills-install.md).

### From source

```sh
git clone https://github.com/henrikrexed/AI-Performance-Testing.git
cd AI-Performance-Testing
```

You'll need Python 3.11+, Node.js 20+, and (only for the EXECUTE stage) k6. Without k6 the
skills degrade gracefully to a `node --check` syntax pass. This is the checkout the
no-backend example below uses.

## Try it with no backend (~10 minutes)

Run the first half of the loop on the bundled synthetic example — no tenant, no tokens.
From a source checkout:

```sh
# SCOPE: synthetic extraction -> a G0-validated model + a human-readable proposal
(cd skills/workload-model && python3 scripts/build_example.py \
  && cat out/example-frontend/scenario-proposal.md)

# SYNTHESIZE: turn the committed example model into a runnable k6 script (V2a gate)
(cd skills/k6-synthesis \
  && node bin/synthesize.mjs ../../examples/workload-model.example.json /tmp/example-out)
```

Read the proposal, then look at what SYNTHESIZE generated. The example artifacts under
[`examples/`](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/examples)
show exactly what each stage produces. This is also where you'll see the V1 gate in action:
synthesis **refuses** a model that hasn't been approved.

## Run the full live loop (with a Dynatrace trial)

When you want the real thing, point KnightLoad at your own backend:

1. Copy `.env.example` to `.env` and fill in `DT_ENDPOINT` and `DT_API_TOKEN` (plus an OTLP
   token if you're exporting). A Dynatrace trial works. See [Requirements](./requirements.md).
2. Install the skills into your coding agent (Claude Code, opencode, Cursor, or any
   agentskills.io agent). See [Installing the skills](./skills-install.md).
3. Ask for the loop in plain language — *"scope a load test for service checkout over the
   last 3 hours"* — and walk the five stages: SCOPE → VALIDATE → SYNTHESIZE → EXECUTE →
   ANALYZE.

The full worked tutorial deploys a small demo AI-agent app, generates a baseline window,
and runs all five stages for real — including the V1 approval gate refusing synthesis until
you sign off.

:::tip Before you share anything
Run `bash tools/secret-scan.sh` from the repo root and make sure it exits clean.
:::

**Next:** [Read the methodology](../how-it-works/index.md) ·
[Full tutorial](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/tutorial) ·
[Token scopes & requirements](./requirements.md)
