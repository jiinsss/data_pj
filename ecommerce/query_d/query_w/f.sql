create table `myetl-474505.ecommerce.fact`
  partition by event_date
  cluster by category_id, brand,event_type as
  select
    event_date,
    event_time,
    event_datetime_kst,
    event_year,
    event_month,
    event_day,
    event_week,
    event_isoyear,
    event_dow,
    event_hour,
    brand,
    price,
    event_type,
    product_id,
    category_id,
    user_id,
    user_session
from `myetl-474505.ecommerce.pre_events`


