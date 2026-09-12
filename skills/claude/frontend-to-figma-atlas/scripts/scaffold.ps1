param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$skillRoot = Split-Path -Parent $PSScriptRoot
$resolvedProject = (Resolve-Path -LiteralPath $ProjectRoot).Path
$toolsRoot = Join-Path $resolvedProject 'tools'
$captureTarget = Join-Path $toolsRoot 'prototype-capture'
$figmaTarget = Join-Path $toolsRoot 'figma-screenshot-importer'

New-Item -ItemType Directory -Force -Path $toolsRoot | Out-Null

function Copy-Template {
  param([string]$Source, [string]$Target)
  if ((Test-Path -LiteralPath $Target) -and -not $Force) {
    throw "Target already exists: $Target. Use -Force to overwrite template files."
  }
  New-Item -ItemType Directory -Force -Path $Target | Out-Null
  Copy-Item -Path (Join-Path $Source '*') -Destination $Target -Recurse -Force
}

Copy-Template -Source (Join-Path $skillRoot 'assets/prototype-capture-template') -Target $captureTarget
Copy-Template -Source (Join-Path $skillRoot 'assets/figma-screenshot-importer') -Target $figmaTarget

$example = Join-Path $captureTarget 'src/scenarios.example.mjs'
$scenarios = Join-Path $captureTarget 'src/scenarios.mjs'
if (-not (Test-Path -LiteralPath $scenarios)) {
  Copy-Item -LiteralPath $example -Destination $scenarios
}

Write-Output "SCAFFOLD_PASS project=$resolvedProject"
Write-Output "Capture tool: $captureTarget"
Write-Output "Figma importer: $figmaTarget"
