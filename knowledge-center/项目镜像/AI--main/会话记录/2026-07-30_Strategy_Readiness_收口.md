# 2026-07-30 Strategy Readiness 收口

## 目标

从已完成的 Binance Testnet V2 工程闭环继续，完成五周期历史数据、不可变 Golden Baseline、策略就绪判定和知识同步；不修改订单或风险配置。

## 结果

- 历史 provenance：`artifacts/strategy_refactor/history-provenance-2026-07-29.json`，状态 `COMPLETE`。
- BTC/ETH 每个标的覆盖：1m 1,879,200；5m 375,840；15m 125,280；1h 31,320；4h 7,830；十条序列零 gaps。
- Final Holdout：2026-01-29..2026-07-29，冻结但未读取结果。
- legacy portfolio：1,126 trades；Sharpe -0.1096；PF 0.9882；MaxDD 77.14%；net expectancy -0.000202；net return -22.71%。
- 判定：数据已就绪，当前策略被拒绝；优化方法学仍需 next-bar parity、真实 point-in-time costs、逐窗口 walk-forward 和 dependent bootstrap。

## 修复

Golden Baseline 原先把缩进 JSON 直接拼接进 `trades.jsonl`，导致单笔交易跨多行。生成器改为紧凑单行 JSON，新增独立逐行解析回归测试。旧不可变产物不删除、不覆盖；中间版本因最终同步、并发 research-candidate commits 和项目强制的 pytest 状态刷新依次失效，corrected `r4` 为权威交付。

## 安全边界

本轮未提交、取消或修改任何交易所订单；未修改 5%/40x、仓位、止损止盈、net-edge、策略规则或晋级门槛；未使用 Final Holdout 调参。

## 验证

- `py -3 -m pytest -q tests/scripts/test_generate_strategy_golden_baseline.py tests/scripts/test_backfill_strategy_refactor_history.py`：`18 passed`。
- `ruff check .`：`All checks passed!`
- `mypy`：`Success: no issues found in 214 source files`
- `py -3 -m pytest -q`：`1231 passed, 16 skipped, 7 warnings`
- `git diff --check`：通过，仅有既有 Windows LF/CRLF 提示。
