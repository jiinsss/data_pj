select
  category_id,
  event_hour,
  COUNTIF(event_type='purchase') as purchases
from `myetl-474505.ecommerce.fact`
where event_date between '2019-10-10' and '2019-10-16'
group by category_id, event_hour
order by category_id, event_hour;
