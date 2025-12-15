SELECT
loc.State,
loc.City,
COUNTIF(f.Severity >= 3) AS sev3_total,
COUNTIF(f.Severity >= 3 AND EXTRACT(HOUR FROM f.Start_Time) BETWEEN 7 AND 9) AS sev3_morning
FROM my-dbtbq-test.my_dataset.fact_model AS f
JOIN my-dbtbq-test.my_dataset.location_model AS loc
ON f.dim_location_id = loc.dim_location_id
GROUP BY loc.State, loc.City