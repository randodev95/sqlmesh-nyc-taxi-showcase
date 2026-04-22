MODEL (
  name taxi.int_trip_enriched,
  kind FULL,
  grain (pickup_ts, dropoff_ts, pu_location_id, do_location_id),
);

SELECT
  t.pickup_ts,
  t.dropoff_ts,
  t.pickup_date,
  t.pu_location_id,
  t.do_location_id,
  pickup_zone.borough AS pickup_borough,
  pickup_zone.zone AS pickup_zone,
  dropoff_zone.borough AS dropoff_borough,
  dropoff_zone.zone AS dropoff_zone,
  t.passenger_count,
  t.trip_distance,
  t.fare_amount,
  t.total_amount,
  t.payment_type,
  t.trip_duration_minutes
FROM taxi.stg_yellow_trips AS t
LEFT JOIN taxi.stg_taxi_zones AS pickup_zone
  ON t.pu_location_id = pickup_zone.location_id
LEFT JOIN taxi.stg_taxi_zones AS dropoff_zone
  ON t.do_location_id = dropoff_zone.location_id
