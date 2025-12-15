
-- Use the `ref` function to select from other models

{{config(materialized='table',cluster_by=['dim_road_id'])}}

SELECT DISTINCT
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
  ))) AS dim_road_id,
  Amenity,
  Bump,
  Crossing,
  Give_Way,
  Junction,
  No_Exit,
  Railway,
  Roundabout,
  Station,
  Stop,
  Traffic_Calming,
  Traffic_Signal,
  Turning_Loop
FROM {{ source('raw_data', 'raw_us_accidents') }}
