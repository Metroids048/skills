---
name: binance-public-market-data
description: Fetch Binance public market data through a credential-free read-only PowerShell wrapper for quant and alpha research without exposing trading or account operations.
---

# Binance Public Market Data

Use `scripts/binance-public-market-data.ps1` for allowlisted public GET endpoints only: ticker, klines, and exchange information. The wrapper has no order, account, trade, listen-key, signing, or credential code. Never add an API key or use this skill to validate live trading.

Example: `pwsh -File scripts/binance-public-market-data.ps1 -Endpoint ticker -Symbol BTCUSDT`.
