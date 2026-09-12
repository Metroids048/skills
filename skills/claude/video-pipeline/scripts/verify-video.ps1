param(
  [Parameter(Mandatory=$true)][string]$Path,
  [double]$ExpectedDuration = 0,
  [double]$ToleranceSeconds = 1.0
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "VIDEO_FILE_MISSING" }
$probe = & ffprobe -v error -show_entries format=duration:stream=codec_type -of json -- "$Path" 2>&1
if ($LASTEXITCODE -ne 0) { throw "FFPROBE_FAILED" }
$obj = $probe | ConvertFrom-Json
$duration = [double]$obj.format.duration
$types = @($obj.streams | ForEach-Object { $_.codec_type })
if ($duration -le 0) { throw "DURATION_INVALID" }
if ($ExpectedDuration -gt 0 -and [math]::Abs($duration-$ExpectedDuration) -gt $ToleranceSeconds) { throw "DURATION_OUT_OF_TOLERANCE" }
if (-not ($types -contains 'video')) { throw "VIDEO_STREAM_MISSING" }
[pscustomobject]@{ path=(Resolve-Path -LiteralPath $Path).Path; duration_seconds=$duration; video_stream=($types -contains 'video'); audio_stream=($types -contains 'audio'); playable=$true }
