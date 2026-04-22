MODEL (
  name taxi.fct_yellow_trip_daily,
  kind FULL,
  grain (pickup_date, pu_location_id),
);

SELECT
  pickup_date,
  pu_location_id,
  COALESCE(pickup_borough, 'Unknown') AS pickup_borough,
  COALESCE(pickup_zone, 'Unknown') AS pickup_zone,
  COUNT(*) AS trip_count,
  SUM(passenger_count) AS passenger_count,
  SUM(total_amount) AS total_amount,
  AVG(trip_distance) AS avg_trip_distance,
  AVG(trip_duration_minutes) AS avg_trip_duration_minutes,
  @safe_divide(SUM(total_amount), COUNT(*)) AS avg_revenue_per_trip
FROM taxi.int_trip_enriched
GROUP BY 1, 2, 3, 4
