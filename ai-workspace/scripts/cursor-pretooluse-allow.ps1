param()

$ErrorActionPreference = "Stop"

try {
  $null = [Console]::In.ReadToEnd()
}
catch {
}

[Console]::Out.Write('{}')
exit 0
