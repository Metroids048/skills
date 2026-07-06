$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')

$dest = Join-Path $env:USERPROFILE '.ai-workspace\vendor\awesome-copilot'
if (-not (Test-Path (Join-Path $dest 'skills'))) {
    $zip = Join-Path $env:TEMP 'awesome-copilot.zip'
    $url = 'https://github.com/github/awesome-copilot/archive/refs/heads/main.zip'
    Write-Host "Downloading $url ..."
    Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing -TimeoutSec 180
    $ex = Join-Path $env:TEMP 'ac-ex'
    if (Test-Path $ex) { Remove-Item $ex -Recurse -Force }
    Expand-Archive -LiteralPath $zip -DestinationPath $ex -Force
    $inner = Get-ChildItem -LiteralPath $ex -Directory | Select-Object -First 1
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Move-Item -LiteralPath $inner.FullName -Destination $dest
}

$configPath = Join-Path $PSScriptRoot 'skills-sync.config.json'
$exclusive = @{}
if (Test-Path $configPath) {
    $raw = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($raw.exclusiveGroups) {
        foreach ($g in $raw.exclusiveGroups) {
            foreach ($n in $g) { $exclusive[$n] = @($g) }
        }
    }
}

$installed = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($root in @('.cursor', '.claude', '.codex')) {
    $p = Join-Path $env:USERPROFILE ($root + '\skills')
    if (Test-Path $p) {
        Get-ChildItem $p -Directory | ForEach-Object { [void]$installed.Add($_.Name) }
    }
}

$acRoot = Join-Path $dest 'skills'
$count = 0
$cap = 15
$added = [System.Collections.Generic.List[string]]::new()

Get-ChildItem -Path $acRoot -Filter 'SKILL.md' -Recurse -File | Sort-Object FullName | ForEach-Object {
    if ($count -ge $cap) { return }
    $skillDir = $_.DirectoryName
    $folder = Split-Path $skillDir -Leaf
    if ($folder.StartsWith('awesome-')) { return }
    if ($installed.Contains($folder)) { return }
    $skip = $false
    if ($exclusive.ContainsKey($folder)) {
        foreach ($peer in $exclusive[$folder]) {
            if ($peer -ne $folder -and $installed.Contains($peer)) { $skip = $true; break }
        }
    }
    if ($skip) { return }
    foreach ($r in @('.cursor', '.claude', '.codex')) {
        $link = Join-Path $env:USERPROFILE ($r + '\skills\' + $folder)
        if (Test-Path $link) { cmd /c "rmdir `"$link`"" | Out-Null }
        cmd /c "mklink /J `"$link`" `"$skillDir`"" | Out-Null
    }
    [void]$installed.Add($folder)
    $added.Add($folder)
    $count++
    Write-Host "Installed: $folder"
}

Write-Host "awesome-copilot cherry-pick count: $count"
$added | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $env:USERPROFILE '.ai-workspace\memory\awesome-copilot-installed.json') -Encoding UTF8
