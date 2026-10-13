---
id: index
title: Exporters
sidebar_label: Overview
description: One approved workload model, four load tools — k6, JMeter, Gatling, Locust — each declaring where it approximates.
slug: /exporters
---

# Exporters

One approved workload model, four load tools. Every renderer reads the same `§4` model as
its only contract and emits `synthetic=true` baggage on every request so the generated
traffic stays identifiable. Each one also publishes a capability report that declares,
honestly, where it approximates the model instead of matching it exactly.

| Exporter | Fit | Arrival model | `synthetic=true` |
|---|---|---|---|
| [**k6**](./k6.md) | native | open & closed, native | OTel baggage + span per request |
| [**JMeter**](./jmeter.md) | established teams | open via Concurrency TG + Throughput Shaping Timer; closed native | `baggage` request header |
| [**Gatling**](./gatling.md) | Scala sims | open & closed, native | protocol header + trace-context |
| [**Locust**](./locust.md) | Python shapes | open approximated via `LoadTestShape` + pacing; closed native | OTel baggage per request |

:::note A note on honesty
Every renderer ships a `supports()` capability report that names its approximations before
it renders. A closed-native tool asked to reproduce an open arrival model will say so.
We'd rather you see the seam than trust a perfect-looking fit that isn't.
:::
