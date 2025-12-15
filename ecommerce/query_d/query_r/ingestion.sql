load data into `myetl-474505.ecommerce.raw_events`
from files (
  format = 'PARQUET',
  uris = ['gs://my_bucket_98881_data/processed/ecommerce/2019-10/*.parquet']
);

