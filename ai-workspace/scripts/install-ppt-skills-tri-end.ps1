# Install PPT/slides skills to Cursor + Claude + Codex via vendor junctions.
param(
    [switch]$DryRun,
    [switch]$SkipClone
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'ensure-utf8-console.ps1')
. (Join-Path $PSScriptRoot 'Write-Utf8NoBom.ps1')

$vendor = Join-Path $env:USERPROFILE '.ai-workspace\vendor'
$cursorSkills = Join-Path $env:USERPROFILE '.cursor\skills'
$claudeSkills = Join-Path $env:USERPROFILE '.claude\skills'
$codexSkills = Join-Path $env:USERPROFILE '.codex\skills'

function Remove-LinkOrDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
        if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force }
    }
    elseif ($item.PSIsContainer) {
        if (-not $DryRun) { Remove-Item -LiteralPath $Path -Recurse -Force }
    }
    else {
        if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force }
    }
}

function Install-SkillJunction {
    param(
        [string]$SkillName,
        [string]$TargetDir
    )
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        Write-Warning "Missing target: $TargetDir"
        return $false
    }
    $resolved = (Resolve-Path -LiteralPath $TargetDir).Path
    foreach ($root in @($cursorSkills, $claudeSkills, $codexSkills)) {
        if (-not (Test-Path $root)) {
            if (-not $DryRun) { New-Item -ItemType Directory -Path $root -Force | Out-Null }
        }
        $dest = Join-Path $root $SkillName
        if ($DryRun) {
            Write-Host "[dry-run] junction $dest -> $resolved"
            continue
        }
        Remove-LinkOrDir -Path $dest
        New-Item -ItemType Junction -Path $dest -Target $resolved | Out-Null
        Write-Host "Junction: $dest -> $resolved"
    }
    return $true
}

function Ensure-RepoClone {
    param(
        [string]$RepoUrl,
        [string]$DestDir
    )
    if (Test-Path (Join-Path $DestDir '.git')) {
        Write-Host "Repo exists: $DestDir"
        return $true
    }
    if (Test-Path $DestDir) {
        $hasContent = Get-ChildItem -LiteralPath $DestDir -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($hasContent) {
            Write-Host "Vendor dir exists (no .git): $DestDir"
            return $true
        }
    }
    if ($DryRun) {
        Write-Host "[dry-run] clone/download $RepoUrl -> $DestDir"
        return $true
    }
    New-Item -ItemType Directory -Path (Split-Path $DestDir -Parent) -Force | Out-Null

    # Zip first — git clone often hangs on restricted networks
    if ($RepoUrl -match 'github\.com/([^/]+)/([^/.]+)') {
        $owner = $Matches[1]
        $repo = $Matches[2]
        foreach ($url in @(
            "https://github.com/$owner/$repo/archive/refs/heads/main.zip",
            "https://github.com/$owner/$repo/archive/refs/heads/master.zip"
        )) {
            try {
                Write-Host "Trying zip: $url"
                $tempZip = Join-Path $env:TEMP ("skill-vendor-$owner-$repo.zip")
                $extractRoot = Join-Path $env:TEMP ("skill-vendor-$owner-$repo")
                Invoke-WebRequest -Uri $url -OutFile $tempZip -UseBasicParsing -TimeoutSec 90
                if (Test-Path $extractRoot) { Remove-Item -LiteralPath $extractRoot -Recurse -Force }
                Expand-Archive -LiteralPath $tempZip -DestinationPath $extractRoot -Force
                $inner = Get-ChildItem -LiteralPath $extractRoot -Directory | Select-Object -First 1
                if (-not $inner) { continue }
                if (Test-Path $DestDir) { Remove-Item -LiteralPath $DestDir -Recurse -Force }
                Move-Item -LiteralPath $inner.FullName -Destination $DestDir
                Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
                Remove-Item -LiteralPath $extractRoot -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "Downloaded zip -> $DestDir"
                return $true
            }
            catch {
                Write-Warning "Zip failed ($url): $_"
            }
        }
    }

    $gitOk = $false
    try {
        $job = Start-Job -ScriptBlock { param($u,$d) git clone --depth 1 $u $d 2>&1 | Out-Null; return $LASTEXITCODE } -ArgumentList $RepoUrl, $DestDir
        if (Wait-Job $job -Timeout 45) {
            $code = Receive-Job $job
            if ($code -eq 0 -and (Test-Path $DestDir)) { $gitOk = $true }
        }
        else {
            Stop-Job $job -Force -ErrorAction SilentlyContinue
            Remove-Job $job -Force -ErrorAction SilentlyContinue
            Write-Warning "git clone timed out: $RepoUrl"
        }
    }
    catch { $gitOk = $false }
    if ($gitOk) { return $true }

    Write-Warning "All download methods failed: $RepoUrl"
    return $false
}

# SkillName = junction folder name; VendorKey = vendor subdir; SkillsRoot = path under vendor (relative)
$skillDefs = @(
    @{ SkillName = 'bruce-pptx-generator'; VendorKey = 'bruce-pptx-generator'; Url = 'https://github.com/bruc3van/bruce-pptx-generator.git'; SkillsRoot = '.' },
    @{ SkillName = 'guizang-ppt-skill'; VendorKey = 'guizang-ppt-skill'; Url = 'https://github.com/op7418/guizang-ppt-skill.git'; SkillsRoot = '.' },
    @{ SkillName = 'html-slide-to-pptx'; VendorKey = 'html-slide-to-pptx'; Url = 'https://github.com/kkennyss/html-slide-to-pptx.git'; SkillsRoot = '.' },
    @{ SkillName = 'revealjs'; VendorKey = 'revealjs-skill'; Url = 'https://github.com/ryanbbrown/revealjs-skill.git'; SkillsRoot = 'skills/revealjs' },
    @{ SkillName = 'awesome-ai-ppt'; VendorKey = 'awesome-ai-ppt'; Url = 'https://github.com/ningzimu/awesome-ai-ppt.git'; SkillsRoot = 'skills/awesome-ai-ppt' },
    @{ SkillName = 'ppt-master'; VendorKey = 'ppt-master'; Url = 'https://github.com/hugohe3/ppt-master.git'; SkillsRoot = 'skills/ppt-master' },
    @{ SkillName = 'frontend-slides'; VendorKey = 'frontend-slides'; Url = 'https://github.com/zarazhangrui/frontend-slides.git'; SkillsRoot = '.' },
    @{ SkillName = 'huashu-design'; VendorKey = 'huashu-design'; Url = 'https://github.com/alchaincyf/huashu-design.git'; SkillsRoot = '.' }
)

$report = [System.Collections.Generic.List[object]]::new()

foreach ($def in $skillDefs) {
    $repoDir = Join-Path $vendor $def.VendorKey
    if (-not $SkipClone) {
        $cloned = Ensure-RepoClone -RepoUrl $def.Url -DestDir $repoDir
        if (-not $cloned) {
            $report.Add([pscustomobject]@{ Skill = $def.SkillName; Action = 'skip'; Reason = 'clone failed' })
            continue
        }
    }

    $target = if ($def.SkillsRoot -eq '.') { $repoDir } else { Join-Path $repoDir $def.SkillsRoot }
    $skillMd = Join-Path $target 'SKILL.md'
    if (-not (Test-Path $skillMd)) {
        # Fallback: find first SKILL.md under repo
        $found = Get-ChildItem -Path $repoDir -Filter 'SKILL.md' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $target = $found.DirectoryName
            $skillMd = $found.FullName
        }
    }

    if (-not (Test-Path $skillMd)) {
        $report.Add([pscustomobject]@{ Skill = $def.SkillName; Action = 'skip'; Reason = 'SKILL.md not found' })
        continue
    }

    if (Install-SkillJunction -SkillName $def.SkillName -TargetDir $target) {
        $report.Add([pscustomobject]@{ Skill = $def.SkillName; Action = 'install'; Reason = $def.Url })
    }
    else {
        $report.Add([pscustomobject]@{ Skill = $def.SkillName; Action = 'skip'; Reason = 'junction failed' })
    }
}

$reportPath = Join-Path $env:USERPROFILE '.ai-workspace\memory\ppt-skills-install-report.json'
if (-not $DryRun) {
    $json = $report | ConvertTo-Json -Depth 3
    Write-Utf8NoBomFile -Path $reportPath -Content $json
}
$report | Format-Table -AutoSize
Write-Host "Report: $reportPath"
Write-Host "Installed: $(($report | Where-Object { $_.Action -eq 'install' }).Count) / $($skillDefs.Count)"
