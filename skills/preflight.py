#!/usr/bin/env python3
"""Install-time pre-flight verification for AI-Performance-Testing skills.

Run standalone:      python3 skills/preflight.py
Or via setup:        sh skills/setup.sh  (runs this as its final step)
Invoked by the one-liner installers after `workload-engine init`.

Design goal: any missing tool is reported HERE, at install time, with the
exact command to fix it — never as a late mid-task runtime failure.

The public skills are deliberately dependency-free (stdlib-only Python,
zero npm packages), so there are no pip manifests or lockfiles to install:
verification covers the toolchain itself.

Check tiers:
  REQUIRED — hard failure (exit 1). The SCOPE/SYNTHESIZE phases cannot run
             without these.
  EXECUTE  — warning only. Needed only when actually executing load tests /
             DQL probes; model and render work never touches these CLIs.

Exit codes: 0 = all required tools present (warnings allowed), 1 = action
needed. --strict makes EXECUTE-tier warnings fatal as well.
"""

from __future__ import annotations

import shutil
import subprocess
import sys

REQUIRED = "REQUIRED"
EXECUTE = "EXECUTE"

# CLI -> (tier, install hint)
EXECUTE_CLIS = {
    "k6": "execute load tests (loadtest-run) | install: https://k6.io/docs/get-started/installation/",
    "dtctl": "Dynatrace DQL probes (baseline-diff, workload-model tiers) | install: see docs/requirements.md",
}


class Result:
    def __init__(self, tier, name, ok, detail, fix):
        self.tier, self.name, self.ok, self.detail, self.fix = tier, name, ok, detail, fix


def check_python() -> Result:
    ok = sys.version_info >= (3, 9)
    return Result(
        REQUIRED, "python",
        ok,
        f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}" + ("" if ok else " (need >= 3.9)"),
        "install Python >= 3.9: https://www.python.org/downloads/",
    )


def run_cmd(cmd: list[str]) -> tuple[bool, str]:
    try:
        out = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        return out.returncode == 0, (out.stdout or out.stderr).strip().splitlines()[0] if (out.stdout or out.stderr) else ""
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return False, ""


def check_node() -> Result:
    ok, out = run_cmd(["node", "--version"])
    if not ok:
        return Result(REQUIRED, "node", False, "MISSING (need >= 18 for k6-synthesis and `node --check`)",
                      "install Node.js >= 18: https://nodejs.org/en/download (or via your package manager)")
    major = int(out.lstrip("v").split(".")[0])
    ok = major >= 18
    return Result(REQUIRED, "node", ok, f"{out}" + ("" if ok else " (need >= 18)"),
                  "" if ok else "upgrade Node.js to >= 18: https://nodejs.org/en/download")


def check_cli(name: str, hint: str) -> Result:
    found = shutil.which(name) is not None
    return Result(EXECUTE, f"cli:{name}", found, "found" if found else "not found", "" if found else hint)


def main() -> int:
    strict = "--strict" in sys.argv
    results = [check_python(), check_node()]
    results += [check_cli(c, h) for c, h in EXECUTE_CLIS.items()]

    hard_fail = [r for r in results if r.tier == REQUIRED and not r.ok]
    warn_fail = [r for r in results if r.tier == EXECUTE and not r.ok]

    print("[AI-Performance-Testing] skill dependency pre-flight")
    print("  skills: workload-model, k6-synthesis, loadtest-run, baseline-diff, rum-sessions, session-stitch\n")
    for r in results:
        mark = "OK  " if r.ok else ("MISS" if r.tier == REQUIRED else "warn")
        print(f"  {mark}  [{r.tier:8s}] {r.name}: {r.detail}")
        if not r.ok and r.fix:
            print(f"        -> {r.fix}")

    print()
    if hard_fail:
        print(f"RESULT: FAIL — {len(hard_fail)} required tool{'s' if len(hard_fail) != 1 else ''} missing.")
        print("  Fix with the install commands above, then re-run:  python3 skills/preflight.py")
        return 1
    if warn_fail and strict:
        print(f"RESULT: FAIL (--strict) — {len(warn_fail)} execute-time tool(s) missing.")
        return 1
    if warn_fail:
        print(f"RESULT: OK for model/render work — {len(warn_fail)} execute-time tool(s) missing (warned above);")
        print("  install them before EXECUTE-phase load runs (see docs/requirements.md).")
        return 0
    print("RESULT: OK — all required and execute-time tools present.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
