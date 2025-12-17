CREATE TABLE IF NOT EXISTS `myetl-474505.nmoney.stock_staging` (
  symbol STRING,
  date DATE,
  open FLOAT64,
  high FLOAT64,
  low FLOAT64,
  close FLOAT64,
  volume INT64
);
