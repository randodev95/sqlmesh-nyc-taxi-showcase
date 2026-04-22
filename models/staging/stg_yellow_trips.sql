MODEL (
  name taxi.stg_yellow_trips,
  kind INCREMENTAL_BY_TIME_RANGE (
    time_column pickup_date
  ),
  grain (pickup_ts, dropoff_ts, pu_location_id, do_location_id),
  audits (
    assert_non_negative_fare,
    assert_positive_trip_duration
  ),
);

WITH typed AS (
  SELECT
    CAST(tpep_pickup_datetime AS TIMESTAMP) AS pickup_ts,
    CAST(tpep_dropoff_datetime AS TIMESTAMP) AS dropoff_ts,
    CAST(tpep_pickup_datetime AS DATE) AS pickup_date,
    CAST(PULocationID AS INTEGER) AS pu_location_id,
    CAST(DOLocationID AS INTEGER) AS do_location_id,
    CAST(passenger_count AS DOUBLE) AS passenger_count,
    CAST(trip_distance AS DOUBLE) AS trip_distance,
    CAST(fare_amount AS DOUBLE) AS fare_amount,
    CAST(total_amount AS DOUBLE) AS total_amount,
    CAST(payment_type AS INTEGER) AS payment_type,
    DATEDIFF('minute', CAST(tpep_pickup_datetime AS TIMESTAMP), CAST(tpep_dropoff_datetime AS TIMESTAMP)) AS trip_duration_minutes
  FROM taxi.raw_yellow_trips
)
SELECT *
FROM typed
WHERE
  pickup_date BETWEEN @start_date AND @end_date
  AND pickup_ts IS NOT NULL
  AND dropoff_ts IS NOT NULL
  AND pu_location_id IS NOT NULL
  AND do_location_id IS NOT NULL
  AND trip_distance >= 0
  AND trip_duration_minutes > 0
  AND fare_amount >= 0
  AND total_amount >= 0
