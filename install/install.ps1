# One-step binary onboarding for AI-Performance-Testing (workload-engine).
#
#   irm https://github.com/henrikrexed/AI-Performance-Testing/releases/latest/download/install.ps1 | iex
#
# Fetches the workload-engine binary + skills bundle for Windows from a GitHub
# Release (checksum-verified against SHA256SUMS), unpacks into
# %LOCALAPPDATA%\KnightLoad, installs the skills into your coding agent via
# `workload-engine init --from ...`, and prints the quickstart. No repo clone,
# no Python toolchain, no admin rights.
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

Write-Host ''
Write-Host 'Installed:'
Write-Host "  engine : $bin"
Write-Host "  skills : $skillsDir"
Write-Host ''
Write-Host 'Quickstart:'
Write-Host "  $bin --extract <extract.json> --out out --mode agentic"
Write-Host "  $bin guided --extract <extract.json> --out out --mode agentic --yes"
Write-Host '  (guided drives propose -> choose -> generate -> try; add --try for a k6 smoke)'
