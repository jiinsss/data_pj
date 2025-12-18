SELECT symbol, date, COUNT(*)
FROM `myetl-474505.nmoney.stock_staging`
GROUP BY symbol, date
HAVING COUNT(*) > 1;
