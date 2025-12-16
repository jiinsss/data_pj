CREATE OR REPLACE TABLE `myetl-474505.ecommerce.d_funnel` AS
WITH session_event_time AS (
  SELECT
    user_session,
    MIN(user_id) AS user_id,

    MIN(CASE WHEN event_type = 'view'
             THEN event_datetime_kst END) AS view_time,

    MIN(CASE WHEN event_type = 'cart'
             THEN event_datetime_kst END) AS cart_time,

    MIN(CASE WHEN event_type = 'purchase'
             THEN event_datetime_kst END) AS purchase_time
  FROM `myetl-474505.ecommerce.fact`
  GROUP BY user_session
),
funnel_valid AS (
  SELECT *
  FROM session_event_time
  WHERE
    view_time IS NOT NULL
    AND (cart_time IS NULL OR cart_time >= view_time)
    AND (purchase_time IS NULL OR purchase_time >= cart_time)
)
SELECT
  f.user_session,
  f.user_id,
  IF(f.view_time IS NOT NULL, 1, 0) AS has_view,
  IF(f.cart_time IS NOT NULL, 1, 0) AS has_cart,
  IF(f.purchase_time IS NOT NULL, 1, 0) AS has_purchase,
FROM funnel_valid f;

