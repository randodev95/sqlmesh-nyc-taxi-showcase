from datetime import date

from scripts.fetch_nyc_taxi_data import month_candidates, month_window, yellow_tripdata_url


def test_month_window_returns_previous_n_months():
    months = month_window(reference=date(2026, 4, 22), months=2)
    assert months == ["2026-02", "2026-03"]


def test_month_window_crosses_year_boundary():
    months = month_window(reference=date(2026, 1, 8), months=3)
    assert months == ["2025-10", "2025-11", "2025-12"]


def test_yellow_tripdata_url_format():
    assert (
        yellow_tripdata_url("2026-03")
        == "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2026-03.parquet"
    )


def test_month_candidates_returns_descending_lookback():
    candidates = month_candidates(reference=date(2026, 4, 22), lookback=4)
    assert candidates == ["2026-03", "2026-02", "2026-01", "2025-12"]
