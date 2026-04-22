MODEL (
  name taxi.stg_taxi_zones,
  kind FULL,
  grain location_id,
);

SELECT
  CAST(LocationID AS INTEGER) AS location_id,
  CAST(Borough AS TEXT) AS borough,
  CAST(Zone AS TEXT) AS zone,
  CAST(service_zone AS TEXT) AS service_zone
FROM taxi.raw_taxi_zones
