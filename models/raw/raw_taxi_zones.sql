MODEL (
  name taxi.raw_taxi_zones,
  kind FULL,
  grain LocationID,
);

SELECT *
FROM read_csv_auto('data/raw/taxi_zone_lookup.csv', header=true)
