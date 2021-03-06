SELECT
 B.user_id as user_id,
 A.time as time,
 A.module_id as module_id,
 A.event as event,
 A.event_type as event_type,
 B.gender AS gender,
 B.mode AS mode,
 CASE
   WHEN B.sum_dt < 1800 THEN "under_30_min"
   WHEN ((B.sum_dt >= 1800) & (B.sum_dt < 18000)) THEN "30_min_to_5_hr"
   WHEN B.sum_dt >= 18000 THEN "over_5_hr"
 END as activity_level
FROM (
SELECT
  time,
  module_id,
  event,
  event_type,
  context.user_id
FROM (TABLE_QUERY( {course}_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN {table_date} and 20380101" ) )
WHERE
  event_type contains "openassessment" AND
  event contains "submission_uuid" AND
  event contains "score_type" AND
  time > PARSE_UTC_USEC("{date}")
) AS A
INNER JOIN (
  SELECT
    user_id,
    gender,
    mode,
    sum_dt
  FROM [ubcxdata:{course}.person_course]
     WHERE
    sum_dt IS NOT NULL) AS B
ON
  A.context.user_id == B.user_id
ORDER BY
  time
LIMIT
  {limit}
