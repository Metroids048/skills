# Run a .ps1 script with explicit UTF-8 read (PS 5.1 -File may misparse no-BOM scripts).
# Prefer Python for scripts with heavy CJK text.
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$ScriptArgs
)

$ErrorActionPreference = 'Stop'

. (Join-Path $env:USERPROFILE '.ai-workspace\scripts\ensure-utf8-console.ps1')

$verify = Join-Path $env:USERPROFILE '.ai-workspace\scripts\verify-ps1-script-encoding.ps1'
& $verify -Path $Path
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$resolved = Resolve-Path -LiteralPath $Path
$bytes = [System.IO.File]::ReadAllBytes($resolved.Path)

if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $content = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
}
else {
    $content = [System.Text.Encoding]::UTF8.GetString($bytes)
}

$scriptBlock = [ScriptBlock]::Create($content)
if ($ScriptArgs -and $ScriptArgs.Count -gt 0) {
    & $scriptBlock @ScriptArgs
}
else {
    & $scriptBlock
}
