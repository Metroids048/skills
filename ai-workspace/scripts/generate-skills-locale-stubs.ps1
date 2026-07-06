# Wrapper: generate locale stubs via Node (UTF-8 safe on Windows).
param([switch]$DryRun)

$ErrorActionPreference = 'Stop'
$nodeScript = Join-Path $PSScriptRoot 'generate-skills-locale-stubs.js'
$args = @($nodeScript)
if ($DryRun) { $args += '--dry-run' }
& node @args
