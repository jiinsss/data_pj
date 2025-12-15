CREATE TABLE `myetl-474505.ecommerce.raw_events_sample` AS
WITH sampled_sessions AS (
  SELECT DISTINCT user_session
  FROM `myetl-474505.ecommerce.raw_events`
  WHERE RAND() < 0.01
)

SELECT *
FROM `myetl-474505.ecommerce.raw_events`
WHERE user_session IN (SELECT user_session FROM sampled_sessions);

