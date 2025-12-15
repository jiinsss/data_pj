
-- Use the `ref` function to select from other models

{{config(materialized='table',cluster_by=['dim_location_id'])}}

SELECT DISTINCT
	FORMAT('%s|%s|%s|%s',
	COALESCE(Zipcode, 'NA'),
    COALESCE(State, 'NA'),
	COALESCE(City, 'NA'),
	COALESCE(Street, 'NA')
    ) AS dim_location_id,
	COALESCE(State, 'NA') AS State,
	COALESCE(County, 'NA') AS County,
	COALESCE(City, 'NA') AS City,
	COALESCE(Street, 'NA') AS Street,
	COALESCE(Zipcode, 'NA') AS Zipcode,
	COALESCE(Timezone, 'NA') AS Timezone, 
	COALESCE(Airport_Code, 'NA') AS Airport_Code
	
FROM {{ source('raw_data','raw_us_accidents') }}