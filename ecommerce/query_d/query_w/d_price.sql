create table `myetl-474505.ecommerce.dim_price` AS
select distinct
  price,
  case
    when price <= 30 then 'very_low'
    when price <= 100 then 'low'
    when price <= 300 then 'mid'
    when price <= 1000 then 'high'
    else 'very_high'
  end as price_bucket
from `myetl-474505.ecommerce.pre_events`;