param(
  [ValidateSet('ticker','klines','exchangeInfo')][string]$Endpoint = 'ticker',
  [ValidatePattern('^[A-Z0-9]{5,20}$')][string]$Symbol = 'BTCUSDT',
  [ValidateSet('1m','5m','15m','1h','4h','1d')][string]$Interval = '1m',
  [ValidateRange(1,1000)][int]$Limit = 5
)
$ErrorActionPreference = 'Stop'
$base = 'https://api.binance.com/api/v3/'
switch ($Endpoint) {
  'ticker' { $uri = $base + 'ticker/price?symbol=' + $Symbol }
  'klines' { $uri = $base + 'klines?symbol=' + $Symbol + '&interval=' + $Interval + '&limit=' + $Limit }
  'exchangeInfo' { $uri = $base + 'exchangeInfo?symbol=' + $Symbol }
}
if ($uri -match 'order|account|trade|listenKey') { throw 'PRIVATE_ENDPOINT_BLOCKED' }
$result = Invoke-RestMethod -Method Get -Uri $uri
$result | ConvertTo-Json -Depth 8
