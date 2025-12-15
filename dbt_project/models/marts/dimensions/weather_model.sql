
-- Use the `ref` function to select from other models

{{config(materialized='table',cluster_by=['dim_weather_id'])}}

SELECT DISTINCT
	FORMAT('%s|%s|%s',
    COALESCE(FORMAT_TIMESTAMP('%Y-%m-%d %H:00:00', Weather_Timestamp), 'NA'),
    COALESCE(LOWER(TRIM(State)), 'NA'),
	COALESCE(LOWER(TRIM(City)), 'NA')
  ) AS dim_weather_id,
  Weather_Timestamp,
  Temperature_F,
  Wind_Chill_F,
  Humidity_Pct,
  Pressure_in,
  Visibility_mi,
  COALESCE(Wind_Direction, 'NA') AS Wind_Direction,
  Wind_Speed_mph,
  Precipitation_in,
  COALESCE(Weather_Condition, 'NA') AS Weather_Condition
FROM {{ source('raw_data', 'raw_us_accidents') }}
