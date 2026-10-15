# skills/setup.ps1 — install-time dependency verification for AI-Performance-Testing
# skills. Windows counterpart of skills/setup.sh.
#
# The public skills are deliberately dependency-free (stdlib-only Python, zero
# npm packages), so setup = toolchain verification: skills/preflight.py reports
# any missing tool with the exact fix — never a late mid-task failure.
#
# Usage:   powershell -ExecutionPolicy Bypass -File skills\setup.ps1
$ErrorActionPreference = "Stop"
$SkillsRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "== AI-Performance-Testing skill setup =="

$Python = if (Get-Command python -ErrorAction SilentlyContinue) { "python" }
          elseif (Get-Command py -ErrorAction SilentlyContinue) { "py -3" }
          else { $null }
if (-not $Python) {
  Write-Error "python not found - install Python >= 3.9 first: https://www.python.org/downloads/"
  exit 1
}

Write-Host "-- pre-flight verification ($Python)"
Invoke-Expression "$Python `"$SkillsRoot\preflight.py`""
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "== setup complete: skill toolchain verified =="
