create table `myetl-474505.ecommerce.dim_category` as 
select distinct
  category_id,
  category_code,
  case
    when category_code = 'no_code' then 'no_code'
    else 'code'
  end as category_type,  
  
  case
    when category_code = 'no_code' then 'no_code'
    else split(category_code, '.')[safe_offset(0)]
  end as category_bucket,
  case
    when category_code = 'no_code' then 'no_code'
    else split(category_code, '.')[safe_offset(1)]
  end as category_bucket2
  
from `myetl-474505.ecommerce.pre_events`;

