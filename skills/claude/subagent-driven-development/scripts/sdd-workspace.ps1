param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'; New-Item -ItemType Directory -Force -Path $Path | Out-Null
Write-Output (Resolve-Path -LiteralPath $Path).Path
