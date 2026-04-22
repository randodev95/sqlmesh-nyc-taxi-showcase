AUDIT (
  name assert_positive_trip_duration,
);

SELECT *
FROM @this_model
WHERE trip_duration_minutes <= 0
