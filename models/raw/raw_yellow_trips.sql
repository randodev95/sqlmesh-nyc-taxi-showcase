MODEL (
  name taxi.raw_yellow_trips,
  kind FULL,
  grain (VendorID, tpep_pickup_datetime, tpep_dropoff_datetime, PULocationID, DOLocationID),
);

SELECT *
FROM read_parquet('data/raw/yellow_tripdata_*.parquet', union_by_name=true)
