"""Shared CLI for the workload-model engine — the entry point the released binary and the
Docker image invoke.

    workload-engine --extract <extract.json> --out <dir> [--mode commerce|agentic]

Input: a **neutral telemetry extract** (JSON) produced by a backend adapter (the dtctl/DQL
query pack in SKILL.md, or any other backend). Output: `<dir>/workload-model.json` +
`<dir>/scenario-proposal.md`, self-validated by the G0 gate. Exit 0 iff G0 passes.

The engine is backend- and tool-agnostic: it never talks to Dynatrace or to a load tool. It
turns neutral facts into a workload model and gates it. The behavioral split is the same
engine across domains — commerce (Buyer / Browser, split on the order-terminal service) and
agentic apps (Agentic / Conversational, split on the `execute_tool` tool-use signal); see
`archetypes.classify_by_terminal`.

`--extract` defaults to the bundled synthetic commerce fixture, so `--help` and a no-arg demo
run work out of the box. The commerce path is identical to `build_example.py` (the skill's
worked example). The agentic path expects an agentic-shaped extract (keys documented in
`_build_agentic`); produce one with the agentic query pack.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import shaping as sh                                            # noqa: E402
from archetypes import AGENTIC_TOOL_PATTERNS, classify_by_terminal  # noqa: E402
from build_example import build_commerce                       # noqa: E402
from clustering import Journey                                 # noqa: E402
from emit import build_model, render_proposal                  # noqa: E402
from g0_gate import evaluate_g0                                # noqa: E402


def _default_fixture() -> Path:
    """Bundled synthetic commerce fixture. Works both from source (`fixtures/`) and inside a
    PyInstaller one-file binary (data files are unpacked to `sys._MEIPASS`)."""
    for cand in (Path(getattr(sys, "_MEIPASS", HERE)) / "example_extract.json",
                 HERE.parent / "fixtures" / "example_extract.json"):
        if cand.exists():
            return cand
    return HERE.parent / "fixtures" / "example_extract.json"


def _bl(d: dict) -> dict:
    return {"p50Ms": d["p50_ms"], "p95Ms": d["p95_ms"], "p99Ms": d["p99_ms"],
            "errorRate": d.get("errorRate", 0.0)}


def _build_agentic(fx: dict):
    """Agentic (Agentic / Conversational) SCOPE assembly from a neutral agentic extract.

    Expected `fx` keys: `service`, `environment`, `timeframe`, `front_end.resolved_op`,
    `code_refs{entry_handler,llm_call}`, `archetype_split{conversational_weight,
    agentic_weight,conversational_traces,agentic_traces,coverage,tools_observed}`,
    `turn_baseline_agent_turn{conversational,agentic}` (each p50_ms/p95_ms/p99_ms),
    `span_trees{conversational,agentic}`, `per_minute_cov.interior_counts`,
    `arrival{arrival_rate_tps,mean_server_response_ms,observed_concurrency}`,
    `access_log_availability`, `sampling_ratio`. Returns (model, proposal, coverage).
    """
    split = fx["archetype_split"]
    bl = fx["turn_baseline_agent_turn"]
    cr = fx.get("code_refs", {})
    entry_op = fx["front_end"]["resolved_op"]

    def journey(aid, name, weight, baseline, flow, payload_ref):
        return {
            "id": aid, "description": f"{name}. Reconstructed flow: {flow}",
            "weight": round(weight, 4), "entrypoint": entry_op,
            "codeRef": cr.get("entry_handler"), "evidenceSource": "span",
            "steps": [
                {"id": "s1", "service": fx["service"], "operation": "POST /request",
                 "callType": "http", "codeRef": cr.get("entry_handler"),
                 "evidenceSource": "span", "payloadRef": payload_ref},
                {"id": "s2", "service": fx["service"], "operation": "llm.call",
                 "callType": "http", "codeRef": cr.get("llm_call"), "evidenceSource": "span"},
            ],
            "baseline": _bl(baseline),
        }

    journeys = [
        journey("conversational", "Conversational — pure-LLM turn (no tool)",
                split["conversational_weight"], bl["conversational"],
                fx["span_trees"]["conversational"], "prompt_chat"),
        journey("agentic", "Agentic — tool-using ReAct turn (reaches execute_tool)",
                split["agentic_weight"], bl["agentic"],
                fx["span_trees"]["agentic"], "prompt_agentic"),
    ]
    # Prove the split is structural (not hardcoded): classify the member ops by tool-use.
    _demo = classify_by_terminal(
        [Journey(op="agentic.turn", traces=split["agentic_traces"],
                 svc_set={fx["service"], "execute_tool"}),
         Journey(op="chat.turn", traces=split["conversational_traces"], svc_set={fx["service"]})],
        patterns=AGENTIC_TOOL_PATTERNS,
        present=("agentic", "Agentic"), absent=("conversational", "Conversational"))
    assert {a.id for a in _demo} == {"agentic", "conversational"}

    stages, _cov = sh.shape_ramp(fx["per_minute_cov"]["interior_counts"])
    arr = fx["arrival"]
    llc = sh.littles_law(arr["arrival_rate_tps"], arr["mean_server_response_ms"],
                         arr["observed_concurrency"])

    model = build_model(
        name=fx["service"], target_service=fx["service"], environment=fx["environment"],
        generated_at=fx.get("generated_at", "1970-01-01T00:00:00Z"),
        timeframe=fx["timeframe"], timeframe_notes="agentic app; terminal signal = execute_tool",
        queries=["see the agentic query pack — adapter ran these live"],
        access_log_availability=fx["access_log_availability"],
        sampling_ratio=fx["sampling_ratio"], arrival_model="open",
        stages=[vars(s) for s in stages], littles_law=vars(llc),
        journeys=journeys,
        payloads={
            "prompt_agentic": {"fields": [{"name": "task", "type": "string",
                "generator": "const", "values": ["use a tool to answer"], "distribution": "uniform"}], "seed": 42},
            "prompt_chat": {"fields": [{"name": "task", "type": "string",
                "generator": "const", "values": ["answer from knowledge"], "distribution": "uniform"}], "seed": 42},
        },
        caps={"maxRps": 2, "maxVus": 20, "maxDuration": "30m"},
        coverage=split["coverage"],
    )
    proposal = render_proposal(
        model, exclusions="none within service scope",
        target_env=fx.get("deployment_environment", "non-production"),
        abort_note="abort above the agentic tail (tool turns run heavier than chat turns)",
        risks_extra=[f"Tools observed: {split.get('tools_observed')}.",
                     "Behavioral split via archetypes.classify_by_terminal "
                     "(terminal signal = execute_tool) — same engine as commerce (order-terminal)."],
    )
    return model, proposal, split["coverage"]


def run(extract: dict, out_dir: Path, mode: str) -> int:
    if mode == "commerce":
        model, proposal, _arch, _cov = build_commerce(extract)
    else:
        model, proposal, _cov = _build_agentic(extract)

    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "workload-model.json").write_text(json.dumps(model, indent=2) + "\n")
    (out_dir / "scenario-proposal.md").write_text(proposal)

    g = evaluate_g0(model, dql_run_live=True, proposal_text=proposal)
    print(json.dumps(g.to_dict(), indent=2))
    print(f"\nG0 {'PASS' if g.passed else 'FAIL'} ({sum(c.passed for c in g.checks)}/{len(g.checks)})"
          f"  -> {out_dir}/workload-model.json")
    return 0 if g.passed else 1


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(prog="workload-engine", description="workload-model engine CLI (SCOPE)")
    ap.add_argument("--extract", type=Path, default=_default_fixture(),
                    help="neutral telemetry extract JSON (default: bundled synthetic commerce fixture)")
    ap.add_argument("--out", required=True, type=Path, help="output directory")
    ap.add_argument("--mode", default="commerce", choices=["commerce", "agentic"],
                    help="behavioral split: commerce (Buyer/Browser) or agentic (Agentic/Conversational)")
    a = ap.parse_args(argv)
    return run(json.loads(a.extract.read_text()), a.out, a.mode)


if __name__ == "__main__":
    raise SystemExit(main())
