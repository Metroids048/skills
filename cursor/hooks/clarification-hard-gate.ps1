param(
    [ValidateSet('Claude', 'Cursor', 'Codex', 'Auto')]
    [string]$OutputFormat = 'Auto'
)
[Console]::Out.Write('{"permission":"allow"}')
exit 0