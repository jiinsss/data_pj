CREATE OR REPLACE TABLE `myetl-474505.nmoney.mart_stock_daily` AS
WITH base AS (
  SELECT
    symbol,
    date,
    close,
    SAFE_DIVIDE(
      close - LAG(close) OVER (PARTITION BY symbol ORDER BY date),
      LAG(close) OVER (PARTITION BY symbol ORDER BY date)
    ) AS daily_return
  FROM `myetl-474505.nmoney.stock_raw`
)

SELECT
  symbol,
  date,
  close,
  daily_return
FROM base;
