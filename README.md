<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset=".github/assets/knightload-lockup-horizontal.svg">
  <source media="(prefers-color-scheme: light)" srcset=".github/assets/knightload-lockup-horizontal-onlight.png">
  <img alt="KnightLoad" src=".github/assets/knightload-lockup-horizontal-onlight.png" width="460">
</picture>

### Realistic, human-approved load tests — extracted from your own telemetry

**KnightLoad turns your observability data into realistic, human-approved load tests —
with a mandatory human gate and traffic you can always tell apart.**

[![License: MIT](https://img.shields.io/badge/License-MIT-2EE6D6.svg?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/github/v/release/henrikrexed/AI-Performance-Testing?style=flat-square&color=212E50&label=release)](https://github.com/henrikrexed/AI-Performance-Testing/releases)
[![Container](https://img.shields.io/badge/ghcr.io-ai--performance--testing-212E50?style=flat-square&logo=docker&logoColor=white)](https://github.com/henrikrexed/AI-Performance-Testing/pkgs/container/ai-performance-testing)
[![Docs](https://img.shields.io/badge/docs-knightload-FFB23E?style=flat-square)](https://henrikrexed.github.io/AI-Performance-Testing/)

</div>

---

One idea sits under all of it: **your telemetry already knows what your real workload
looks like — extract it, have a human approve it, then replay it faithfully.**

Maintained by [Henrik Rexed](https://www.youtube.com/@IsItObservable) (IsItObservable).
The methodology and toolkit were developed and battle-tested on the
[IsItObservable](https://www.youtube.com/@IsItObservable) channel's cloud-native and AI
benchmarking projects.

## The loop

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"transparent","fontFamily":"'Space Grotesk','Sora','Segoe UI',system-ui,sans-serif","primaryColor":"#212E50","primaryTextColor":"#C7CDD6","primaryBorderColor":"#2EE6D6","secondaryColor":"#1A1A2E","secondaryTextColor":"#C7CDD6","secondaryBorderColor":"#96A0B2","tertiaryColor":"#16213E","tertiaryTextColor":"#C7CDD6","tertiaryBorderColor":"#96A0B2","lineColor":"#2EE6D6","textColor":"#C7CDD6","mainBkg":"#212E50","nodeBorder":"#2EE6D6","clusterBkg":"#16213E","clusterBorder":"#96A0B2","titleColor":"#C7CDD6","edgeLabelBackground":"#16213E","nodeTextColor":"#C7CDD6"}} }%%
flowchart LR
    SCOPE -->|G0| VALIDATE -->|V1| SYNTHESIZE -->|V2a| EXECUTE -->|V2b| ANALYZE
    ANALYZE -->|"V3 — iterate (parameter-only, ≤3×) or escalate"| SCOPE
```

| Stage | What happens | Who owns it |
|---|---|---|
| **SCOPE** | extraction queries over a clean telemetry window → journeys, arrival profiles, think-times, payload strategy (`workload-model.json`) | you / your coding agent |
| **VALIDATE** | a human reads `scenario-proposal.md` and approves, adjusts, or rejects — recorded in the model, revision-bound | **a human, always** |
| **SYNTHESIZE** | approved model → runnable k6 / JMeter / Gatling / Locust project + synthetic payload pools (V2a static checks) | you / your agent |
| **EXECUTE** | small confirmation test first (six pass criteria), then a capped, abort-guarded full run | you / your agent |
| **ANALYZE** | shape-diff of test vs baseline across six dimensions → accept / iterate / escalate | machine + human cap |

Why it is built this way:

- **Realism is measured, not guessed** — journeys, arrival rates, and think-times come
  from your own telemetry (spans, access logs, RUM sessions, OTel `session.id`). Nothing
  is assumed where a number can be extracted.
- **A human gate is mandatory** — no test runs against any environment before a person
  approves the workload model (Gate V1). Approval is bound to the exact model revision;
  edit the model and the approval is void. Fail-closed everywhere downstream.
- **Tests are code you can read** — every generated test is committed, diffable, and
  reviewable. Regeneration is deterministic given the same model and seed — no black-box
  recorder, no artifact you can't inspect.
- **Synthetic traffic stays identifiable** — generated load carries `synthetic=true`
  baggage promoted to a queryable attribute, so test and real traffic never blur — even
  when they share an environment.

## How you use it — the guided flow

You don't run a pile of scripts by hand. You talk to your coding agent (Claude Code,
opencode, Cursor, …); **KnightLoad drives the engine and stops at exactly the human
decision points.** Four steps, mapped 1:1 onto the loop:

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"transparent","fontFamily":"'Space Grotesk','Sora','Segoe UI',system-ui,sans-serif","primaryColor":"#212E50","primaryTextColor":"#C7CDD6","primaryBorderColor":"#2EE6D6","secondaryColor":"#1A1A2E","secondaryTextColor":"#C7CDD6","secondaryBorderColor":"#96A0B2","tertiaryColor":"#16213E","tertiaryTextColor":"#C7CDD6","tertiaryBorderColor":"#96A0B2","lineColor":"#2EE6D6","textColor":"#C7CDD6","mainBkg":"#212E50","nodeBorder":"#2EE6D6","clusterBkg":"#16213E","clusterBorder":"#96A0B2","titleColor":"#C7CDD6","edgeLabelBackground":"#16213E","nodeTextColor":"#C7CDD6","noteBkgColor":"#FFB23E","noteTextColor":"#16213E","noteBorderColor":"#FFB23E"}} }%%
flowchart TB
    S1["1 · Propose + confirm<br/>engine extracts the workload model;<br/>you get a diff-able summary"]
    S2["2 · Choose output<br/>k6 / JMeter / Gatling / Locust<br/>(one or several)"]
    S3["3 · Generate the project<br/>full runnable load test —<br/>scripts, feeders, config, README"]
    S4["4 · Try it? (opt-in)<br/>short smoke run + results summary"]
    S1 -->|"V1 — you confirm or edit"| S2 --> S3 -->|"you opt in"| S4
```

| Step | What happens | Loop stage | Who decides |
|---|---|---|---|
| **1 · Propose + confirm** | The agent runs the engine to extract/propose the workload model from your telemetry (or the bundled synthetic extract) and shows it as a readable summary — endpoints, mix %, arrival/ramp, think-times. | SCOPE → **V1 gate** | **you** (the gate) |
| **2 · Choose output** | The agent asks which exporter(s) you want — **k6 / JMeter / Gatling / Locust**, one or several. Sane default: k6. | VALIDATE | you pick |
| **3 · Generate the project** | The agent renders the full, runnable load-test project for the chosen exporter(s) into a named folder (e.g. `loadtest-<app>/`) with a one-line "how to run". | SYNTHESIZE | agent / engine |
| **4 · "Try it?"** | The agent offers to run a short smoke test and summarize the results. Optional and user-gated. | EXECUTE → ANALYZE | you opt in |

The honest shape: **the agent proposes, you confirm, the engine generates, the run is
opt-in.** Nothing executes against any environment until you say so.

## Install

One command — engine binary **and** the skills for your coding agent, checksum-verified,
no clone, no root (linux/macOS; the engine binary itself needs no Python or Node):

```sh
curl -fsSL https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.sh | sh
```

Windows (PowerShell):

```powershell
irm https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.ps1 | iex
```

What it does: fetches the latest release's `workload-engine` binary + skills bundle for
your platform (SHA256SUMS-verified), unpacks into `~/.knightload/`
(`%LOCALAPPDATA%\KnightLoad` on Windows), installs the skills into your agent
(`workload-engine init`, default `~/.claude/skills`), runs the install-time dependency
pre-flight (exact fix commands for anything missing), and prints the quickstart.
Override with `KNIGHTLOAD_VERSION` / `KNIGHTLOAD_DIR` / `KNIGHTLOAD_DEST`.

**Docker** (multi-arch: amd64 + arm64) — path unchanged:

```sh
docker pull ghcr.io/henrikrexed/ai-performance-testing:latest   # pin a release with :0.1.7
```

**Manual binary** — current release [`v0.1.7`](https://github.com/henrikrexed/AI-Performance-Testing/releases/tag/v0.1.7);
every release ships binaries for linux-amd64/arm64 · darwin-arm64 · windows-amd64.exe,
each with a CycloneDX SBOM; per-platform commands in [`docs/engine.md`](docs/engine.md).
The commands below always track [`latest`](https://github.com/henrikrexed/AI-Performance-Testing/releases/latest):

```sh
curl -fsSL -o workload-engine \
  "https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/workload-engine-linux-amd64"
chmod +x workload-engine && ./workload-engine --help
```

> `releases/latest/download/…` URLs always fetch the newest release — to pin, swap that
> segment for `releases/download/v0.1.7/…`. The Docker **image** tag is `0.1.7` (no `v`);
> the GitHub **release** that ships the binaries is tagged `v0.1.7`. macOS / Windows /
> Kubernetes paths are in [`docs/engine.md`](docs/engine.md).

**Contributors** — to hack on the repo itself, clone it and install the skills from the
checkout (`python3 engine/cli.py init`, per-agent details in
[`docs/skills-install.md`](docs/skills-install.md)):

```sh
git clone https://github.com/henrikrexed/AI-Performance-Testing.git
cd AI-Performance-Testing && python3 engine/cli.py init
```

### Try it with no backend (~10 minutes)

Run the first half of the loop on the bundled synthetic example — no tenant, no tokens,
no clone. After the one-command install above:

```sh
# SCOPE: synthetic extract -> a G0-validated model + a human-readable proposal
# (stamped provenance.kind=demo-sample — demo data is never silently selectable)
curl -fsSL https://raw.githubusercontent.com/henrikrexed/AI-Performance-Testing/main/examples/crewai-deepseek-agent/extract.json -o extract.json
~/.knightload/bin/workload-engine --extract extract.json --out out --mode agentic
cat out/scenario-proposal.md

# SYNTHESIZE: turn the committed example model into a runnable k6 script (V2a gate)
# (--demo: the example model is demo-stamped; renderers refuse demo data without opt-in)
curl -fsSL https://raw.githubusercontent.com/henrikrexed/AI-Performance-Testing/main/examples/workload-model.example.json -o workload-model.example.json
node ~/.claude/skills/k6-synthesis/bin/synthesize.mjs workload-model.example.json example-out --demo
```

Read the proposal, then look at what SYNTHESIZE generated — this is also where you see the
V1 gate in action: synthesis **refuses** a model that hasn't been approved. Continue in
[`tutorial/README.md`](tutorial/README.md) for the full walkthrough.

## Exporters

One approved model renders to any of four industry-standard runners — pick per prompt:

| Exporter | What you get |
|---|---|
| **k6** | The native fit — open & closed arrival, Zipf payload pools. |
| **JMeter** | Concurrency Thread Group + Throughput Shaping Timer, CSV data sets. |
| **Gatling** | A single Scala Simulation with JSON feeders. |
| **Locust** | `locustfile.py` with `LoadTestShape` pacing and shared feeders. |

## How it fits together

The deterministic core is backend-agnostic. Today the extraction and analysis seam is
Dynatrace (Grail/DQL); the clustering / shaping / emission / gates don't care where the
data came from, and the generated tests are plain runner projects that run anywhere.

```mermaid
%%{init: {"theme":"base","themeVariables":{"darkMode":true,"background":"transparent","fontFamily":"'Space Grotesk','Sora','Segoe UI',system-ui,sans-serif","primaryColor":"#212E50","primaryTextColor":"#C7CDD6","primaryBorderColor":"#2EE6D6","secondaryColor":"#1A1A2E","secondaryTextColor":"#C7CDD6","secondaryBorderColor":"#96A0B2","tertiaryColor":"#16213E","tertiaryTextColor":"#C7CDD6","tertiaryBorderColor":"#96A0B2","lineColor":"#2EE6D6","textColor":"#C7CDD6","mainBkg":"#212E50","nodeBorder":"#2EE6D6","clusterBkg":"#16213E","clusterBorder":"#96A0B2","titleColor":"#C7CDD6","edgeLabelBackground":"#16213E","nodeTextColor":"#C7CDD6"}} }%%
flowchart LR
    subgraph BACKEND["Telemetry backend (swappable)"]
        DT["Dynatrace Grail / DQL"]
    end
    subgraph SEAM["Extraction pack"]
        DQL["DQL queries<br/>spans · access logs · RUM"]
    end
    subgraph CORE["Deterministic engine (backend-agnostic)"]
        CL["clustering"] --> SH["shaping"] --> EM["emission"] --> G["gates G0 / V1 / V2"]
    end
    subgraph OUT["Exporters"]
        K6["k6"]
        JM["JMeter"]
        GA["Gatling"]
        LO["Locust"]
    end
    AGENT(["Your coding agent<br/>(KnightLoad skills)"])
    DT --> DQL --> CL
    G --> K6 & JM & GA & LO
    AGENT -.drives.-> DQL
    AGENT -.drives.-> CORE
    AGENT -.drives.-> OUT
```

## Documentation

| Doc | What it covers |
|---|---|
| [`docs/methodology.md`](docs/methodology.md) | The method: principles, the five-stage loop, every gate, dual-source session reconstruction, safety rules, fidelity caveats |
| [`docs/usage.md`](docs/usage.md) | End-to-end usage — no-backend quickstart, running the loop against your own tenant, the full tutorial |
| [`docs/engine.md`](docs/engine.md) | The workload-model engine: install per platform (binary / Docker / k8s / source) and its role in the loop |
| [`docs/requirements.md`](docs/requirements.md) | Dynatrace tokens + **scopes**, `dtctl` + its agent skill, Davis AI, everything else |
| [`docs/skills-install.md`](docs/skills-install.md) | Installing the skills into Claude Code, opencode, Cursor, or any agentskills.io agent |

The full documentation site lives at
[**henrikrexed.github.io/AI-Performance-Testing**](https://henrikrexed.github.io/AI-Performance-Testing/).

## Configuration

All environment wiring is documented in [`.env.example`](.env.example) — copy to `.env`,
fill in your values, never commit a real `.env`. Two tokens by design: a read-only DQL
token and a separate OTLP ingest token. The exact **token scopes** (including
`storage:user.events:read`, the one that is easy to miss for RUM-driven journeys) and the
`dtctl` setup are in [`docs/requirements.md`](docs/requirements.md).

The backend is currently **Dynatrace (Grail/DQL)** for extraction and analysis. The
deterministic core (clustering, shaping, emission, gates) is backend-agnostic — the DQL
pack is the seam you would reimplement for another backend. Generated tests are plain
k6 / JMeter / Gatling / Locust projects and run anywhere those runners run.

## Requirements

- Python 3.11+, Node.js 20+, k6 (only for EXECUTE; skills degrade to `node --check`)
- A Dynatrace environment (trial works) for the live loop — tokens + scopes in
  [`docs/requirements.md`](docs/requirements.md)
- Each `skills/*/` directory is self-contained with its own tests:
  `python3 -m pytest` / `node --test` inside it

## License

[MIT](LICENSE) — © 2026 Henrik Rexed.
