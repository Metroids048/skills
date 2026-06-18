# Set Windows console to UTF-8 for the current PowerShell session.
# Safe to dot-source from hooks and other scripts (no stdout pollution).

try {
    chcp 65001 | Out-Null
} catch { }

[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
