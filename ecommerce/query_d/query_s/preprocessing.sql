CREATE TABLE `myetl-474505.ecommerce.pre_events`
PARTITION BY event_date AS
SELECT
  event_time,
  DATETIME(event_time, "Asia/Seoul") AS event_datetime_kst,
  DATE(event_time, "Asia/Seoul") AS event_date,
  EXTRACT(YEAR FROM DATETIME(event_time, "Asia/Seoul")) AS event_year,
  EXTRACT(MONTH FROM DATETIME(event_time, "Asia/Seoul")) AS event_month,
  EXTRACT(DAY FROM DATETIME(event_time, "Asia/Seoul")) AS event_day,

  EXTRACT(ISOWEEK FROM DATETIME(event_time, "Asia/Seoul")) AS event_week,
  EXTRACT(ISOYEAR FROM DATETIME(event_time, "Asia/Seoul")) AS event_isoyear,
  EXTRACT(DAYOFWEEK FROM DATETIME(event_time, "Asia/Seoul")) AS event_dow,
  EXTRACT(HOUR FROM DATETIME(event_time, "Asia/Seoul")) AS event_hour,

  IFNULL(LOWER(category_code), "no_code") AS category_code,
  IFNULL(LOWER(brand), "no_brand") AS brand,
  IFNULL(price, 0) AS price,
  
  LOWER(event_type) AS event_type,
  CAST(product_id AS INT64) AS product_id,
  CAST(category_id AS INT64) AS category_id,
  CAST(user_id AS INT64) AS user_id,
  CAST(user_session AS STRING) AS user_session

FROM `myetl-474505.ecommerce.raw_events`;
