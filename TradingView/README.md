# TradingView Pine Scripts

Pine Script strategies that mirror or prototype the EAs in this repo. They are
useful for quick visual prototyping, optimisation, and backtesting before
porting the final logic to MT5 / MQL5.

## JJ Simon Fair Value Theory - NQ/MNQ

`JJSimon_FairValue_NQ.pine` is a Pine Script **v6** `strategy()` script
implementing the JJ Simon Fair Value Theory tailored for NASDAQ futures
(NQ / MNQ) on the **1-minute** timeframe during the **New York** session.

### Highlights
- Fair value lines anchored to the **09:30** and **14:00** NY opens (with
  optional dynamic colour and right-extension).
- **BOS / MSB** structure detection using configurable pivots, confirmed on
  candle close (no repaint).
- Mechanical **displacement candle** filter: body >= ATR multiplier and
  counter-wick / body ratio <= 20% (configurable).
- **Continuation** entries (BOS + displacement away from FV) and
  **Mean Reversion** entries (MSB + displacement extended from FV) with
  ATR/point-based distance gates.
- **ATR volatility regime** auto-selecting SL / TP buckets:
  - ATR > 20 -> SL 50 / TP 75 points
  - 7 <= ATR <= 20 -> SL 25 / TP 37.5 points
  - ATR < 7 -> SL 16.5 / TP 24.75 points
  - Optional fixed-RR override (default 1:1.5).
- Funded-account-friendly risk gating: max trades / session, daily loss cap,
  one trade per direction per session, post-loss cooldown, no pyramiding,
  optional break-even and trailing stop (off by default).
- Chop filter: minimum ATR, minimum session expansion, no-trade buffer
  around fair value, optional 50-EMA slope trend filter.
- Visuals: FV lines, VWAP, BOS / MSB labels, displacement markers, entry
  arrows, SL / TP boxes, session shading, backtest analytics table.
- Alerts for BOS, MSB, displacement, continuation, mean reversion and final
  buy / sell signals.

### How to load
1. Open TradingView and load an `NQ` or `MNQ` chart on the **1m** timeframe.
2. Open the **Pine Editor** at the bottom of the chart.
3. Open a new tab, paste the contents of `JJSimon_FairValue_NQ.pine`, and
   click **Save**, then **Add to chart**.
4. Open the strategy settings to tune the inputs, grouped by:
   1. Market & Session
   2. Fair Value
   3. Market Structure
   4. Displacement Candle
   5. Entry Models
   6. VWAP Filter
   7. ATR Volatility Regime
   8. Risk Management
   9. Chop Filter
   10. Visualisation

### Notes for MT5 porting
- All entry conditions are mechanical and rely only on confirmed candle data,
  ATR, pivot highs/lows and clock-based session windows.
- SL / TP are expressed in NQ points (configurable), so the same numbers map
  cleanly to MQL5 once the symbol point/tick conversion is applied.
- Comment tags on entries (`L_CONT`, `L_MR`, `S_CONT`, `S_MR`) make it
  straightforward to track continuation vs. mean-reversion stats in the EA.
