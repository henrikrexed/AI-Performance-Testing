---
id: gatling
title: Gatling — Scala simulations
sidebar_label: Gatling
description: Produces a single Gatling Simulation class in Scala plus JSON feeders, with native open/closed arrival.
slug: /exporters/gatling
---

# Gatling — Scala simulations

Produces a single Gatling `Simulation` class in Scala plus JSON feeders. Arrival profiles
map to `constantUsersPerSec` / `rampUsersPerSec` (open) or `constantConcurrentUsers` /
`rampConcurrentUsers` (closed, with max concurrency from Little's Law). Journey mix becomes
a `randomSwitch`; correlation uses `.check(... saveAs)` into session attributes. Payload
pools become JSON feeders materialized as a Zipf multiset so `.random` reproduces the hit
ratio. `synthetic=true` is set as an HTTP protocol header alongside W3C trace-context
propagation.

| | |
|---|---|
| **Arrival model** | open and closed, native |
| **Feeders / payloads** | JSON feeders as a Zipf multiset reproducing the hit ratio |
| **`synthetic=true`** | `httpProtocol.header("baggage","synthetic=true")` + trace-context |
| **Declared approximations** | per-step exponential/empirical think-times fall back to a mean pause; HTML-DOM extraction falls back to regex |

See [`skills/gatling-synthesis`](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/skills/gatling-synthesis)
and [How it works](../how-it-works/index.md) for where this sits in the loop.
