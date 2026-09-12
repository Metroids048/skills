param([Parameter(Mandatory=$true)][string]$Task,[string]$Output='task-brief.md')
$ErrorActionPreference='Stop'; @("# Task brief",'',"## Objective",$Task,'',"## Safety",'Read-only or synthetic validation by default.') | Set-Content -LiteralPath $Output -Encoding UTF8
Write-Output (Resolve-Path -LiteralPath $Output).Path
