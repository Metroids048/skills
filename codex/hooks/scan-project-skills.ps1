param(
    [ValidateSet('Cursor', 'Claude', 'Codex', 'Plain')]
    [string]$OutputFormat = 'Plain',
    [ValidateSet('SessionStart', 'UserPromptSubmit', 'Plain')]
    [string]$HookEvent = 'Plain',
    [string]$StartDir = ''
)
$mapEvent = switch ($HookEvent) {
    'SessionStart' { 'SessionStart' }
    'UserPromptSubmit' { 'UserPromptSubmit' }
    default { 'Plain' }
}
& 'C:\Users\win\.ai-workspace\scripts\scan-global-skills.ps1' -OutputFormat $OutputFormat -HookEvent $mapEvent -StartDir $StartDir
exit $LASTEXITCODE
