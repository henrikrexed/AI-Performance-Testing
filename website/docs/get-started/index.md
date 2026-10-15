---
id: index
title: Get started
sidebar_label: Overview & quickstart
description: Install the released engine (binary or Docker), the skills, or run from source — then walk the loop, the no-backend example first and the full live loop when you're ready.
slug: /get-started
---

import DemoClip from '@site/src/components/DemoClip';

# Get started

First get the tool, then walk the loop. Start with the no-backend example to see what each
stage produces, then run the full live loop against your own tenant when you're ready.

For what you need before the live loop — tokens, scopes, and agent tooling — see
[Requirements](./requirements.md). To install the skills into your coding agent, see
[Installing the skills](./skills-install.md). For every engine install path (per-platform
binary, Docker, Kubernetes, source), see [The engine](./engine.md).

## Install

Pick the path that fits. The fastest way to run SCOPE is the **released engine** — a
checksum-verified installer, a standalone binary, or a container, no Python toolchain
required. To drive the whole loop from your coding agent, install the **skills**. To hack
on the code, clone the **source**.

### Fastest — the released engine (installer, Docker, or binary)

The engine ships as a standalone `workload-engine` binary and a multi-arch container
(amd64 + arm64) on every release. The current release is
[**`v0.1.6`**](https://github.com/henrikrexed/AI-Performance-Testing/releases/tag/v0.1.6);
the commands below always track
[`latest`](https://github.com/henrikrexed/AI-Performance-Testing/releases/latest).

**One-liner installer** — platform binary + the skills, checksum-verified against
`SHA256SUMS`, installed into `~/.knightload` (Windows: `install.ps1` from the same URL):

```sh
curl -fsSL https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.sh | sh
```

**Docker:**

```sh
docker pull ghcr.io/henrikrexed/ai-performance-testing:latest   # pin a release with :0.1.6
```

:::note
The **image** tag is `0.1.6` (no `v`); the GitHub **release** that ships the binaries is
tagged `v0.1.6`. `releases/latest/download/…` URLs always fetch the newest release — to
pin, swap that segment for `releases/download/v0.1.6/…`.
:::

**Binary** — download the one for your platform. Each binary ships a CycloneDX SBOM
(`<binary>.cyclonedx.json`) and a `.sha256` checksum next to it:

```sh
curl -fsSL -o workload-engine \
  "https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/workload-engine-linux-amd64"
chmod +x workload-engine && ./workload-engine --help
```

macOS (Apple Silicon), Windows, and a one-shot Kubernetes `Job` are all in
[The engine](./engine.md) §1.

### Install — engine + skills, one command

The release installer fetches the `workload-engine` binary + skills bundle for your
platform (SHA256SUMS-verified, no clone), installs the skills into your agent (default
`~/.claude/skills`), verifies them, and runs the dependency pre-flight:

```sh
curl -fsSL https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.sh | sh
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
# SCOPE: synthetic extraction -> a G0-validated model + human-readable proposal
# (output is stamped provenance.kind=demo-sample — demo data is never silently selectable)
(cd skills/workload-model && python3 scripts/build_example.py \
  && cat out/example-frontend/scenario-proposal.md)

# SYNTHESIZE: turn the committed example model into a runnable k6 script (V2a gate)
# --demo: the example model is demo-stamped; renderers refuse demo data without opt-in
(cd skills/k6-synthesis \
  && node bin/synthesize.mjs ../../examples/workload-model.example.json /tmp/example-out --demo)
```

<DemoClip name="utility" aspect="800 / 508" caption="Steps 1–2 in action: SCOPE drafts the workload profile, the V1 gate confirms it, and SYNTHESIZE emits the runnable k6 script." />

Read the proposal, then look at what SYNTHESIZE generated. The example artifacts under
[`examples/`](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/examples)
show exactly what each stage produces. Two guards are visible here: drop `--demo` from
the SYNTHESIZE command and the renderer refuses the model outright (demo data is never
silently selectable — `--demo` or `WORKLOAD_MODEL_ALLOW_DEMO=1` is the explicit opt-in),
and synthesis also refuses any model a human hasn't approved (the V1 gate).

## Run the full live loop (with a Dynatrace trial)

When you want the real thing, point KnightLoad at your own backend:

1. Copy `.env.example` to `.env` and fill in `DT_ENDPOINT` and `DT_API_TOKEN` (plus an OTLP
   token if you're exporting). A Dynatrace trial works. See [Requirements](./requirements.md).
2. Install the skills into your coding agent (Claude Code, opencode, Cursor, or any
   agentskills.io agent). See [Installing the skills](./skills-install.md).
3. Ask for the loop in plain language — *"scope a load test for service checkout over the
   last 3 hours"* — and walk the five stages: SCOPE → VALIDATE → SYNTHESIZE → EXECUTE →
   ANALYZE.

The first live-run step is a **fail-closed environment probe**
(`skills/workload-model/scripts/env_probe.py`: `dtctl` present · DQL reachable · target
observed in the window). No probe, no extraction — and never a silent fallback to the
bundled example. Every model the loop builds is stamped with its provenance
(`extracted` from your tenant, or `demo-sample`), so demo data cannot masquerade as a
real scan.

The full worked tutorial deploys a small demo AI-agent app, generates a baseline window,
and runs all five stages for real — including the V1 approval gate refusing synthesis until
you sign off.

:::tip Before you share anything
Run `bash tools/secret-scan.sh` from the repo root and make sure it exits clean.
:::

**Next:** [Read the methodology](../how-it-works/index.md) ·
[Full tutorial](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/tutorial) ·
[Token scopes & requirements](./requirements.md)
