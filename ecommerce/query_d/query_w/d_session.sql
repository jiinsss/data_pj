create table `myetl-474505.ecommerce.dim_session` as
with session_duration as (
  select 
    user_session,
    timestamp_diff(max(event_datetime_kst), min(event_datetime_kst), second) as session_sec
    from `myetl-474505.ecommerce.pre_events`
    group by user_session
)
select 
  d.user_session,
  d.session_sec,
  case
    when d.session_sec <=10 then '0-10s'
    when d.session_sec <=30 then '10-30s'
    when d.session_sec <=60 then '30-60s'
    when d.session_sec <=180 then '1-3min'
    else '3min~'
  end as session_bucket
from session_duration d;
