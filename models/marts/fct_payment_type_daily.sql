MODEL (
  name taxi.fct_payment_type_daily,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column pickup_date
  ),
  grain (pickup_date, payment_type),
);

SELECT
  t.pickup_date,
  t.payment_type,
  COALESCE(m.payment_type_name, 'Unmapped') AS payment_type_name,
  COUNT(*) AS trip_count,
  SUM(t.total_amount) AS total_amount,
  @safe_divide(SUM(t.total_amount), COUNT(*)) AS avg_revenue_per_trip
FROM taxi.stg_yellow_trips AS t
LEFT JOIN taxi.seed_payment_type_map AS m
  ON t.payment_type = m.payment_type
WHERE t.pickup_date BETWEEN @start_date AND @end_date
GROUP BY 1, 2, 3
