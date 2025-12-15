create table `myetl-474505.ecommerce.raw_events` (
  event_time TIMESTAMP,
  event_type STRING,
  product_id INT64,
  category_id INT64,
  category_code STRING,
  brand STRING,
  price FLOAT64,
  user_id INT64,
  user_session STRING
)
partition by date(_PARTITIONTIME)
;

