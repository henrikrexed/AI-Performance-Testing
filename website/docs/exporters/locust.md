---
id: locust
title: Locust — Python load shapes
sidebar_label: Locust
description: Renders a locustfile.py with weighted tasks per journey, LoadTestShape pacing, and the same feeders k6 emits.
slug: /exporters/locust
---

# Locust — Python load shapes

Renders a `locustfile.py` with one `HttpUser` and a weighted `@task` per journey, plus lib
helpers and the same pre-generated feeders the k6 renderer emits. Open arrival is
approximated with a `LoadTestShape` plus `constant_pacing` (declared as approximation
**G-O1**); per-stage user counts come from Little's Law, clamped to the VU cap. Correlation
uses fail-fast `require_value` extraction. `synthetic=true` rides as OTel baggage on every
request.

| | |
|---|---|
| **Arrival model** | open approximated via `LoadTestShape` + pacing; closed native |
| **Feeders / payloads** | the same pre-generated Zipf pools as k6 |
| **`synthetic=true`** | OTel baggage per request (best-effort OTel emission) |
| **Declared approximations** | open-arrival shaping (G-O1); empirical think-time sampling (G-E1) |

See [`skills/locust-synthesis`](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/skills/locust-synthesis)
and [How it works](../how-it-works/index.md) for where this sits in the loop.
