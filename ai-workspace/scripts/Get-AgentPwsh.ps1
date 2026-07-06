# Resolve pwsh.exe for Agent hooks and scripts (MSI install preferred over WindowsApps alias).
$ErrorActionPreference = 'Stop'

function Get-AgentPwshPath {
    $candidates = @(
        'C:\Program Files\PowerShell\7\pwsh.exe'
        'C:\Program Files\PowerShell\7-preview\pwsh.exe'
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) { return $p }
    }
    $cmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source -notlike '*WindowsApps*') { return $cmd.Source }
    if ($cmd) { return $cmd.Source }
    throw 'pwsh.exe not found. Install PowerShell 7 MSI.'
}

function Get-AgentPwshCommandPrefix {
    $pwsh = Get-AgentPwshPath
    return "`"$pwsh`" -NoProfile -ExecutionPolicy Bypass"
}

if ($MyInvocation.InvocationName -ne '.') {
    Get-AgentPwshPath
}
