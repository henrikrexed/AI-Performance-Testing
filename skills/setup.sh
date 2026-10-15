#!/bin/sh
# skills/setup.sh — install-time dependency verification for AI-Performance-Testing
# skills. POSIX sh; runs anywhere the installers run (linux/macOS).
#
# The public skills are deliberately dependency-free (stdlib-only Python, zero
# npm packages), so setup = toolchain verification: skills/preflight.py reports
# any missing tool with the exact fix — never a late mid-task failure.
#
# Usage:   sh skills/setup.sh          (from anywhere; resolves its own location)
#          sh skills/setup.sh --strict (also fail on execute-time CLI warnings)
set -eu

SKILLS_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "== AI-Performance-Testing skill setup =="

if command -v python3 >/dev/null 2>&1; then
  PYTHON=python3
elif command -v python >/dev/null 2>&1; then
  PYTHON=python
else
  echo "ERROR: python not found — install Python >= 3.9 first: https://www.python.org/downloads/" >&2
  exit 1
fi

echo "-- pre-flight verification ($PYTHON)"
"$PYTHON" "$SKILLS_ROOT/preflight.py" "$@"

echo "== setup complete: skill toolchain verified =="
