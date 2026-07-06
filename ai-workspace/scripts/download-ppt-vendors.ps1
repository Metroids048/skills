$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$repos = @(
    @{ Name = 'guizang-ppt-skill'; Zip = 'https://github.com/op7418/guizang-ppt-skill/archive/refs/heads/main.zip' },
    @{ Name = 'html-slide-to-pptx'; Zip = 'https://github.com/kkennyss/html-slide-to-pptx/archive/refs/heads/main.zip' },
    @{ Name = 'revealjs-skill'; Zip = 'https://github.com/ryanbbrown/revealjs-skill/archive/refs/heads/main.zip' },
    @{ Name = 'ppt-master'; Zip = 'https://github.com/hugohe3/ppt-master/archive/refs/heads/main.zip' },
    @{ Name = 'frontend-slides'; Zip = 'https://github.com/zarazhangrui/frontend-slides/archive/refs/heads/main.zip' },
    @{ Name = 'huashu-design'; Zip = 'https://github.com/alchaincyf/huashu-design/archive/refs/heads/main.zip' }
)

foreach ($repo in $repos) {
    $dest = Join-Path $vendor $repo.Name
    $hasSkill = Test-Path (Join-Path $dest 'SKILL.md')
    if (-not $hasSkill) {
        $found = Get-ChildItem -Path $dest -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $hasSkill = $true }
    }
    if ($hasSkill) {
        Write-Host "skip (exists): $($repo.Name)"
        continue
    }

    Write-Host "download: $($repo.Name)"
    $zip = Join-Path $env:TEMP ("ppt-vendor-$($repo.Name).zip")
    $ex = Join-Path $env:TEMP ("ppt-vendor-$($repo.Name)-ex")
    Invoke-WebRequest -Uri $repo.Zip -OutFile $zip -UseBasicParsing -TimeoutSec 120
    if (Test-Path $ex) { Remove-Item -LiteralPath $ex -Recurse -Force }
    Expand-Archive -LiteralPath $zip -DestinationPath $ex -Force
    $inner = Get-ChildItem -LiteralPath $ex -Directory | Select-Object -First 1
    if (-not $inner) { throw "No inner dir for $($repo.Name)" }
    if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    Move-Item -LiteralPath $inner.FullName -Destination $dest
    Remove-Item -LiteralPath $zip -Force -ErrorAction SilentlyContinue
    Remove-Item -LiteralPath $ex -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "done: $($repo.Name)"
}

Write-Host 'All downloads complete.'
