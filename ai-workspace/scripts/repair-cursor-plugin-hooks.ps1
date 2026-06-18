# Repairs known Cursor plugin hook issues on Windows (idempotent).
# - Superpowers hooks-cursor.json: extensionless session-start -> run-hook.cmd
# - session-start file: strip accidental UTF-8 garbage before shebang
param(
    [switch]$Quiet
)

$ErrorActionPreference = 'SilentlyContinue'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')
. (Join-Path $PSScriptRoot 'Write-Utf8NoBom.ps1')
$fixed = @()

function Write-RepairLog {
    param([string]$Message)
    if (-not $Quiet) { Write-Host $Message }
    $script:fixed += $Message
}

$superpowersRoot = Join-Path $env:USERPROFILE '.cursor\plugins\cache\cursor-public\superpowers'
if (Test-Path $superpowersRoot) {
    Get-ChildItem -LiteralPath $superpowersRoot -Directory | ForEach-Object {
        $hooksCursor = Join-Path $_.FullName 'hooks\hooks-cursor.json'
        if (Test-Path $hooksCursor) {
            $raw = Get-Content -LiteralPath $hooksCursor -Raw -Encoding UTF8
            $expected = './hooks/run-hook.cmd session-start'
            if ($raw -match '\./hooks/session-start"' -and $raw -notmatch [regex]::Escape($expected)) {
                $updated = $raw -replace '"\./hooks/session-start"', "`"$expected`""
                if ($updated -ne $raw) {
                    Write-Utf8NoBomFile -Path $hooksCursor -Content $updated
                    Write-RepairLog "Fixed hooks-cursor.json -> $hooksCursor"
                }
            }
        }

        $sessionStart = Join-Path $_.FullName 'hooks\session-start'
        if (Test-Path $sessionStart) {
            $bytes = [System.IO.File]::ReadAllBytes($sessionStart)
            $text = [System.Text.Encoding]::UTF8.GetString($bytes)
            if ($text -notmatch '^#!') {
                $clean = $text -replace '^[^#]*(?=#!/usr/bin/env bash)', ''
                if ($clean -ne $text -and $clean -match '^#!/usr/bin/env bash') {
                    Write-Utf8NoBomFile -Path $sessionStart -Content $clean
                    Write-RepairLog "Stripped garbage prefix from session-start -> $sessionStart"
                }
            }
        }
    }
}

# Vendor copy inside Agent Platform repo (if present)
$repoVendor = Join-Path $env:USERPROFILE 'Desktop\Agent Platform\skills\superpowers-main\hooks\hooks-cursor.json'
if (Test-Path $repoVendor) {
    $raw = Get-Content -LiteralPath $repoVendor -Raw -Encoding UTF8
    if ($raw -match '\./hooks/session-start"' -and $raw -notmatch 'run-hook\.cmd session-start') {
        $updated = $raw -replace '"\./hooks/session-start"', '"./hooks/run-hook.cmd session-start"'
        Write-Utf8NoBomFile -Path $repoVendor -Content $updated
        Write-RepairLog "Fixed vendor hooks-cursor.json -> $repoVendor"
    }
}

if ($fixed.Count -eq 0) {
    Write-RepairLog 'repair-cursor-plugin-hooks: no changes needed'
}

exit 0
