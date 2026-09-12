param([Parameter(Mandatory=$true)][string]$Path)
$ErrorActionPreference='Stop'; if(-not(Test-Path -LiteralPath $Path)){throw 'PATH_MISSING'}; Get-ChildItem -LiteralPath $Path -Recurse -File | Select-Object FullName,Length
