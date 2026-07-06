# Cursor/Claude preToolUse Shell — RTK rewrite with fail-open JSON.
param(
    [ValidateSet('Claude', 'Cursor', 'Codex', 'Auto')]
    [string]$OutputFormat = 'Cursor'
)

$format = if ($OutputFormat -eq 'Auto') { 'Cursor' } else { $OutputFormat }

try {
    $rtk = Get-Command rtk -ErrorAction SilentlyContinue
    if ($rtk) {
        $stdinJson = ''
        try { $stdinJson = [Console]::In.ReadToEnd() } catch { }
        if (-not [string]::IsNullOrWhiteSpace($stdinJson)) {
            $out = $stdinJson | & rtk hook cursor 2>$null
            if ($out -and ($out.Trim() -match '^\s*\{')) {
                [Console]::Out.WriteLine($out.Trim())
                exit 0
            }
        }
    }
}
catch { }

if ($format -eq 'Claude') {
    [Console]::Out.WriteLine ((@{
        continue           = $true
        hookSpecificOutput = @{
            hookEventName      = 'PreToolUse'
            permissionDecision = 'allow'
        }
    } | ConvertTo-Json -Compress -Depth 5))
}
else {
    [Console]::Out.WriteLine ((@{ permission = 'allow' } | ConvertTo-Json -Compress))
}
exit 0
