
-- Use the `ref` function to select from other models
{{config(materialized='table', cluster_by=['dim_time_id'])}}

SELECT DISTINCT
	FORMAT_DATE('%Y%m%d%H', DATE(Start_Time)) AS dim_time_id,
	EXTRACT(YEAR FROM Start_Time) AS Year,
	EXTRACT(MONTH FROM Start_Time) AS Month,
	EXTRACT(DAY FROM Start_Time) AS Day,
	EXTRACT(HOUR FROM Start_Time) AS Hour,
	EXTRACT(DAYOFWEEK FROM Start_Time) AS Weekday
	
FROM {{ source('raw_data','raw_us_accidents') }}

