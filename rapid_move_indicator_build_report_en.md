# RapidMove Risk Radar — Experimental Indicator Build Report

**Date:** September 27, 2026  
**Status:** Experimental MQL5 monitoring indicator for Gold and Nasdaq on M1, M5, and M15.

## What was implemented

- Converted the model into an MT5 indicator that plots an orange marker after a candle closes when the risk of a large move during the next three candles is elevated.
- Added a relative risk ranking score from 0 to 100 and an optional alert. The score is not a statistical probability.
- Added separate parameter profiles for Gold and Nasdaq on each timeframe, with automatic selection by symbol name or manual selection.
- Uses OHLC features only and rejects features that cross data gaps. It does not predict buy/sell direction or place orders.

## Out-of-sample validation

The model was revalidated using the same features calculated by the indicator code, across four consecutive test periods. The alert threshold for each period was selected from the preceding validation data. The target event is a one-candle close return within the next three candles whose absolute size exceeds 2.8 times the standard deviation of the last 80 returns.

| Asset | Timeframe | Baseline event rate | Model alert precision | Current-candle-range baseline precision | Events captured by model (average across periods) | Number of alerts |
|---|---:|---:|---:|---:|---:|---:|
| Gold | M1 | 4.8% | 17.5% | 15.1% | 18.8% | 1349 |
| Gold | M5 | 6.4% | 27.2% | 22.3% | 21.0% | 1229 |
| Gold | M15 | 6.3% | 26.8% | 25.9% | 20.7% | 563 |
| Nasdaq | M1 | 5.8% | 24.3% | 19.6% | 21.9% | 1369 |
| Nasdaq | M5 | 6.5% | 42.4% | 34.9% | 28.5% | 1075 |
| Nasdaq | M15 | 7.5% | 35.8% | 39.1% | 20.9% | 469 |

The strongest result was Nasdaq M5: 42.4% of model alerts were followed by a target event, compared with a 6.5% baseline event rate and 34.9% precision for the current-candle-range baseline. Gold M5 reached 27.2%, compared with 22.3% for that baseline. On Nasdaq M15, the simple baseline had higher precision than the model (39.1% versus 35.8%), so results should not be treated as equally strong across timeframes.

## Installation

1. Download and extract the ZIP, or download the MQ5 file directly.
2. In MT5, select **File → Open Data Folder**.
3. Copy the MQ5 file into MQL5/Indicators.
4. Open it in MetaEditor and press **F7**. After it compiles successfully, refresh the Navigator and add the indicator to a Gold or Nasdaq chart on M1, M5, or M15.
5. If the broker's symbol name is not recognized, set InpAssetProfile to Gold or Nasdaq.

## Important limitations

The source could not be compiled in MetaEditor in this environment. Press F7 and check the compiler output in MT5 before testing. The source data came from one broker, and the timezone was not identified. Performance does not establish profitability; previous return tests did not demonstrate a stable trading edge after estimated costs. First test it on a demo account and record alerts without placing trades.
