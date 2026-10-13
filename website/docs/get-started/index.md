---
id: index
title: Get started
sidebar_label: Overview & quickstart
description: Two ways in — the no-backend example, then the full live loop against your own tenant.
slug: /get-started
---

# Get started

Two ways in. Start with the no-backend example to see what each stage produces, then run
the full live loop against your own tenant when you're ready.

For what you need before the live loop — tokens, scopes, and agent tooling — see
[Requirements](./requirements.md). To install the skills into your coding agent, see
[Installing the skills](./skills-install.md). For the engine binary / Docker image, see
[The engine](./engine.md).

## Step 1 — Clone the repo

```sh
git clone https://github.com/henrikrexed/AI-Performance-Testing.git
cd AI-Performance-Testing
```

You'll need Python 3.11+, Node.js 20+, and (only for the EXECUTE stage) k6. Without k6 the
skills degrade gracefully to a `node --check` syntax pass.

## Step 2 — Try it with no backend (~10 minutes)

Run the first half of the loop on the bundled synthetic example — no tenant, no tokens:

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

## Step 3 — Run the full live loop (with a Dynatrace trial)

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
