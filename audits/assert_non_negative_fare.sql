AUDIT (
  name assert_non_negative_fare,
);

SELECT *
FROM @this_model
WHERE fare_amount < 0
