create table `myetl-474505.ecommerce.d_funnel` as
with session_event_flags_time as (
  select
    user_session,
    min(user_id) as user_id,
    min(category_id) as category_id,

    min(case when event_type = 'view'
             then event_datetime_kst end) as view_time,

    min(case when event_type = 'cart'
             then event_datetime_kst end) as cart_time,

    min(case when event_type = 'purchase'
             then event_datetime_kst end) as purchase_time
  from `myetl-474505.ecommerce.fact`
  group by user_session
),

funnel_valid as (
  select *
  from session_event_flags_time
  where
    view_time is not null
    and (cart_time is null or cart_time >= view_time)
    and (purchase_time is null or purchase_time >= cart_time)
)

select
  f.user_session,
  f.user_id,
  c.category_type,
  c.category_bucket,
  c.category_bucket2,
  s.session_bucket,

  if(f.view_time is not null, 1, 0) as has_view,
  if(f.cart_time is not null, 1, 0) as has_cart,
  if(f.purchase_time is not null, 1, 0) as has_purchase
from funnel_valid f
left join `myetl-474505.ecommerce.dim_session` s
  using (user_session)
left join `myetl-474505.ecommerce.dim_category` c
  on f.category_id = c.category_id;
