create table `myetl-474505.ecommerce.d_daily_cohort` as
with cohort_base as (
  select
    user_id,
    min(event_date) as first_visit_date
    from `myetl-474505.ecommerce.fact`
    group by user_id
),
user_daily_visits as (
  select
    user_id,
    event_date as visit_date
    from `myetl-474505.ecommerce.fact`
    group by user_id, visit_date
),
base as (
  select
  v.user_id,
  c.first_visit_date,
  v.visit_date,
  date_diff(v.visit_date,c.first_visit_date,day) as day_diff
  from user_daily_visits v
  join cohort_base c using(user_id)
)
select
  first_visit_date as cohort_date,
  count(distinct case when day_diff=0 then user_id end) as cohort_size,
  count(distinct case when day_diff=1 then user_id end) as d1_users,
  safe_divide(
    count(distinct case when day_diff=1 then user_id end),
    count(distinct case when day_diff=0 then user_id end)
  ) as d1_retention,

  count(distinct case when day_diff=7 then user_id end) as d7_users,
  safe_divide(
    count(distinct case when day_diff=7 then user_id end),
    count(distinct case when day_diff=0 then user_id end)
  ) as d7_retention,

  count(distinct case when day_diff=30 then user_id end) as d30_users,
  safe_divide(
    count(distinct case when day_diff=30 then user_id end),
    count(distinct case when day_diff=0 then user_id end)
  ) as d30_retention

  from base
  group by cohort_date
  order by cohort_date