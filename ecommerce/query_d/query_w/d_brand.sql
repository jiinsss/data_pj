create table `myetl-474505.ecommerce.dim_brand` as 
select distinct
  case
    when brand = 'no_brand' then 'no_brand'
    else brand
  end as brand_bucket
from `myetl-474505.ecommerce.pre_events`;
