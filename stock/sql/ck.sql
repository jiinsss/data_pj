SELECT symbol, date, COUNT(*)
FROM `myetl-474505.nmoney.stock_raw`
GROUP BY symbol, date
HAVING COUNT(*) > 1;
