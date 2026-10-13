---
id: jmeter
title: JMeter — for teams already on JMeter
sidebar_label: JMeter
description: Renders the model to an Apache JMeter .jmx test plan plus CSV data sets, with provenance and a capability report.
slug: /exporters/jmeter
---

# JMeter — for teams already on JMeter

Renders the model to an Apache JMeter `.jmx` test plan plus CSV data sets, with a manifest
recording provenance and the capability report. An open arrival profile maps to a
Concurrency Thread Group driven by a Throughput Shaping Timer; a closed model maps to
native concurrent users. Payload pools become CSV Data Sets. `synthetic=true` is carried as
a request baggage header.

| | |
|---|---|
| **Arrival model** | open via Concurrency Thread Group + Throughput Shaping Timer; closed native |
| **Feeders / payloads** | one CSV Data Set per payload pool |
| **`synthetic=true`** | `baggage` request header |

See [`skills/jmeter-synthesis`](https://github.com/henrikrexed/AI-Performance-Testing/tree/main/skills/jmeter-synthesis)
and [How it works](../how-it-works/index.md) for where this sits in the loop.
