# One-step binary onboarding for AI-Performance-Testing (workload-engine).
#
#   irm https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.ps1 | iex
#
# Fetches the workload-engine binary + skills bundle for Windows from a GitHub
# Release (checksum-verified against SHA256SUMS), unpacks into
# %LOCALAPPDATA%\KnightLoad, installs the skills into your coding agent via
# `workload-engine init --from ...`, runs the install-time dependency
# pre-flight (exact fix commands for anything missing), and prints the
# quickstart. No repo clone, no admin rights. The engine binary itself needs
# no Python or Node.
#
# Overrides (when run as a script, not via iex):
#   .\install.ps1 -Version v0.1.5 -InstallDir C:\bin\KnightLoad -SkillsDest $HOME\.claude\skills
param(
  [string]$Version = "",
  [string]$InstallDir = "",
  [string]$SkillsDest = ""
)

$ErrorActionPreference = 'Stop'
$Repo   = 'henrikrexed/AI-Performance-Testing'
$Engine = 'workload-engine'
$Platform = 'windows-amd64'

if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA 'KnightLoad' }

if (-not $Version) {
  $rel = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases/latest"
  $Version = $rel.tag_name
  if (-not $Version) { throw 'install.ps1: could not resolve the latest release' }
}
$Ver  = $Version.TrimStart('v')
$Base = "https://github.com/$Repo/releases/download/$Version"

Write-Host "==> $Engine $Version ($Platform) -> $InstallDir"

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$tmp = Join-Path $env:TEMP "knightload-$Version"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null

Invoke-WebRequest -Uri "$Base/SHA256SUMS"                -OutFile (Join-Path $tmp 'SHA256SUMS')
Invoke-WebRequest -Uri "$Base/$Engine-$Platform.exe"     -OutFile (Join-Path $tmp "$Engine-$Platform.exe")
Invoke-WebRequest -Uri "$Base/$Engine-skills-$Ver.zip"   -OutFile (Join-Path $tmp "$Engine-skills-$Ver.zip")

# verify before executing anything
$sums = Get-Content (Join-Path $tmp 'SHA256SUMS')
foreach ($name in @("$Engine-$Platform.exe", "$Engine-skills-$Ver.zip")) {
  $expected = ($sums | Where-Object { $_ -match "$name$" } | Select-Object -First 1) -split '\s+' | Select-Object -First 1
  if (-not $expected) { throw "install.ps1: $name not covered by SHA256SUMS" }
  $actual = (Get-FileHash -Path (Join-Path $tmp $name) -Algorithm SHA256).Hash.ToLower()
  if ($actual -ne $expected.ToLower()) { throw "install.ps1: checksum mismatch for $name (expected $expected, got $actual)" }
}

$binDir = Join-Path $InstallDir 'bin'
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
$bin = Join-Path $binDir "$Engine-$Ver.exe"
Copy-Item (Join-Path $tmp "$Engine-$Platform.exe") $bin -Force
# stable unversioned name ($InstallDir\bin\workload-engine.exe) for quickstarts
Copy-Item $bin (Join-Path $binDir "$Engine.exe") -Force

$skillsDir = Join-Path $InstallDir 'skills'
if (Test-Path $skillsDir) { Remove-Item $skillsDir -Recurse -Force }
Expand-Archive -Path (Join-Path $tmp "$Engine-skills-$Ver.zip") -DestinationPath $skillsDir -Force
# the zip has a single top-level dir; flatten so $skillsDir\workload-model\SKILL.md exists
$inner = Get-ChildItem $skillsDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1
if ($inner) {
  Get-ChildItem $inner.FullName | Move-Item -Destination $skillsDir -Force
  Remove-Item $inner.FullName -Recurse -Force
}

Write-Host "==> installing skills into your coding agent ($Engine init)"
$initArgs = @('init', '--from', $skillsDir)
if ($SkillsDest) { $initArgs += @('--dest', $SkillsDest) }
& $bin @initArgs
if ($LASTEXITCODE -ne 0) { throw "install.ps1: $Engine init failed with exit code $LASTEXITCODE" }

# install-time dependency pre-flight: report anything the skills need with the
# exact fix command - never a late mid-task failure. The install itself still
# succeeds; this is a health report, not a gate.
$setup = Join-Path $skillsDir 'setup.ps1'
if (Test-Path $setup) {
  $Python = if (Get-Command python -ErrorAction SilentlyContinue) { 'python' }
            elseif (Get-Command py -ErrorAction SilentlyContinue) { 'py -3' }
            else { $null }
  if ($Python) {
    Write-Host '==> skill dependency pre-flight'
    & powershell -NoProfile -ExecutionPolicy Bypass -File $setup
    if ($LASTEXITCODE -ne 0) {
      Write-Host ''
      Write-Host "  (pre-flight reported missing tools above - the engine and skills are"
      Write-Host "   installed; fix the items marked MISS, then re-run:  powershell -File $setup)"
    }
  } else {
    Write-Host '==> skill dependency pre-flight: SKIPPED (python not found)'
    Write-Host '  the skills need Python >= 3.9 and Node >= 18; install them, then verify:'
    Write-Host "    powershell -ExecutionPolicy Bypass -File $setup"
    Write-Host '  https://www.python.org/downloads/   https://nodejs.org/'
  }
}

$stableBin = Join-Path $binDir "$Engine.exe"
Write-Host ''
Write-Host 'Installed:'
Write-Host "  engine : $stableBin  (-> $bin)"
Write-Host "  skills : $skillsDir  (installed into your agent by '$Engine init')"
Write-Host ''
Write-Host 'Quickstart:'
Write-Host "  $stableBin --extract <extract.json> --out out --mode agentic"
Write-Host "  $stableBin guided --extract <extract.json> --out out --mode agentic --yes"
Write-Host '  (guided drives propose -> choose -> generate -> try; add --try for a k6 smoke)'
Write-Host '  example extract (no clone needed):'
Write-Host "    Invoke-WebRequest -Uri https://raw.githubusercontent.com/$Repo/main/examples/crewai-deepseek-agent/extract.json -OutFile extract.json"
