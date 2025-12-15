
-- Use the `ref` function to select from other models

{{ config( materialized='table',
    partition_by={
      "field": "Start_Time",
      "data_type": "timestamp",
      "granularity": "year"
    },
    cluster_by=['dim_location_id', 'dim_time_id', 'dim_weather_id', 'dim_road_id']
) }}

SELECT
  ID,
  Severity,
  Distance_Mi,
  TIMESTAMP_DIFF(End_Time, Start_Time, MINUTE) AS Duration_Minutes,
  Start_Time,

  -- for fast
  EXTRACT(YEAR FROM Start_Time) AS Year,
  EXTRACT(MONTH FROM Start_Time) AS Month,
  EXTRACT(DAY FROM Start_Time) AS Day,

  -- FK
  FORMAT_DATE('%Y%m%d%H', DATE(Start_Time)) AS dim_time_id,
  FORMAT('%s|%s|%s|%s',
	COALESCE(Zipcode, 'NA'),
    COALESCE(State, 'NA'),
	COALESCE(City, 'NA'),
	COALESCE(Street, 'NA')
	) AS dim_location_id,
	FORMAT('%s|%s|%s',
	COALESCE(FORMAT_TIMESTAMP('%Y-%m-%d %H:00:00', Weather_Timestamp), 'NA'),
	COALESCE(LOWER(TRIM(State)), 'NA'),
	COALESCE(LOWER(TRIM(City)), 'NA')
	) AS dim_weather_id,
  TO_HEX(MD5(CONCAT(
    COALESCE(CAST(Amenity AS STRING), 'NA'), '|',
    COALESCE(CAST(Bump AS STRING), 'NA'), '|',
    COALESCE(CAST(Crossing AS STRING), 'NA'), '|',
    COALESCE(CAST(Give_Way AS STRING), 'NA'), '|',
    COALESCE(CAST(Junction AS STRING), 'NA'), '|',
    COALESCE(CAST(No_Exit AS STRING), 'NA'), '|',
    COALESCE(CAST(Railway AS STRING), 'NA'), '|',
    COALESCE(CAST(Roundabout AS STRING), 'NA'), '|',
    COALESCE(CAST(Station AS STRING), 'NA'), '|',
    COALESCE(CAST(Stop AS STRING), 'NA'), '|',
    COALESCE(CAST(Traffic_Calming AS STRING), 'NA'), '|',
    COALESCE(CAST(Traffic_Signal AS STRING), 'NA'), '|',
    COALESCE(CAST(Turning_Loop AS STRING), 'NA')
  ))) AS dim_road_id
FROM {{ source('raw_data', 'raw_us_accidents') }}