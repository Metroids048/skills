# Strategy Readiness

- 结论：`NO_ACTIVE_STRATEGY / DATA_COVERAGE_INSUFFICIENT`
- 报告：`docs/audit/strategy-readiness-2026-07-30.md`
- 真实数据事实：BTC/ETH 5m 为 0 bars；1m 约 14 天且有长缺口；15m/1h/4h 约 1 年；需要 42 个月训练/OOS/Holdout。
- 验证缺口：legacy technical replay 未建模 funding/latency/spread/partial fill；当前 `bootstrap_ci` 为 IID percentile，不能作为最终晋级 CI；holdout 尚未冻结/读取。
- 纪律：不调 MACD/RSI、不放宽风险/成本门槛、不把 Testnet sampling 当盈利证据。下一步先真实回填数据并重新生成不可变基线。
