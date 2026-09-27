# RapidMove Risk Radar — Experimental

## What it does

The indicator plots an orange dot after a candle closes when the estimated risk of a large price move during the next three candles is elevated. It uses OHLC features from the latest 1, 3, and 10 candles and volatility calculated from the last 80 returns. Returns that cross time gaps are excluded.

- Supported and tested timeframes: M1, M5, and M15.
- Assets: Gold (XAUUSD) and Nasdaq (NDX100/US100; broker symbol names vary).
- It does not predict whether price will move up or down. It places no trades and provides no entry or exit levels.
- The 0–100 score is a relative risk ranking, not a statistical probability.
- Model parameters and thresholds were trained on the uploaded price files. Results may differ with another broker, symbol, or market period.

## Installation in MT5

1. Download the file RapidMove_RiskRadar_Experimental.mq5.
2. In MetaTrader 5, select File → Open Data Folder.
3. Open MQL5/Indicators and copy the MQ5 file there.
4. Open the file in MetaEditor and press F7 to compile it.
5. In MT5, refresh the Navigator, then add the indicator to a Gold or Nasdaq chart on M1, M5, or M15.
6. If the indicator does not recognize your broker's symbol name, set InpAssetProfile manually to Gold or Nasdaq.

The orange dot appears after a candle closes. The chart comment shows the risk score and alert cutoff. Disable pop-up alerts with InpPopupAlert.

## Validation and limitations

The mathematical model was evaluated on four consecutive out-of-sample time periods. The MQL5 source has not been compiled in MetaEditor here, so press F7 in MT5 and check for compiler errors before use. The results were promising for detecting elevated risk, particularly on Nasdaq M5, but they do not establish a profitable buy/sell strategy. Do not use this indicator alone to make trading decisions.
