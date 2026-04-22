MODEL (
  name taxi.seed_payment_type_map,
  kind SEED (
    path '../../seeds/payment_type_map.csv'
  ),
  columns (
    payment_type INTEGER,
    payment_type_name TEXT
  ),
  grain payment_type,
);
