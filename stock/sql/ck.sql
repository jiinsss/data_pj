SELECT symbol, date, COUNT(*) AS cnt
FROM `myetl-474505.nmoney.stock_raw`
WHERE date >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY symbol, date
HAVING cnt > 1;
