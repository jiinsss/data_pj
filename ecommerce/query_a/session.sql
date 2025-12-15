create or replace view `myetl-474505.ecommerce.d_funnel_session` as
select
  session_bucket,

  sum(has_view) as view_sessions,
  sum(has_cart) as cart_sessions,
  sum(has_purchase) as purchase_sessions,

  safe_divide(sum(has_cart), sum(has_view)) as view_to_cart_rate,
  safe_divide(sum(has_purchase), sum(has_cart)) as cart_to_purchase_rate,
  safe_divide(sum(has_purchase), sum(has_view)) as view_to_purchase_rage

  from `myetl-474505.ecommerce.d_funnel`
  group by session_bucket
  order by session_bucket;