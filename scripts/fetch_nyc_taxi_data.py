from __future__ import annotations

import argparse
from datetime import date
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/"
ZONE_LOOKUP_URL = "https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv"


def month_window(reference: date, months: int) -> list[str]:
    if months < 1:
        raise ValueError("months must be >= 1")

    current = date(reference.year, reference.month, 1)
    labels: list[str] = []
    for _ in range(months):
        year = current.year
        month = current.month - 1
        if month == 0:
            year -= 1
            month = 12
        labels.append(f"{year:04d}-{month:02d}")
        current = date(year, month, 1)

    labels.reverse()
    return labels


def month_candidates(reference: date, lookback: int) -> list[str]:
    if lookback < 1:
        raise ValueError("lookback must be >= 1")

    labels: list[str] = []
    year = reference.year
    month = reference.month
    for _ in range(lookback):
        month -= 1
        if month == 0:
            year -= 1
            month = 12
        labels.append(f"{year:04d}-{month:02d}")
    return labels


def yellow_tripdata_url(month_label: str) -> str:
    return f"{BASE_URL}yellow_tripdata_{month_label}.parquet"


def download_file(url: str, destination: Path) -> bool:
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        return True

    request = Request(url, headers={"User-Agent": "sqlmesh-nyc-taxi-showcase/0.1"})
    try:
        with urlopen(request, timeout=120) as response:  # nosec B310 - fixed trusted public dataset URLs
            destination.write_bytes(response.read())
            return True
    except HTTPError as ex:
        if ex.code in (403, 404):
            return False
        raise


def fetch_raw_data(output_dir: Path, months: int) -> None:
    labels: list[str] = []
    for label in month_candidates(reference=date.today(), lookback=max(months * 6, months)):
        url = yellow_tripdata_url(label)
        destination = output_dir / f"yellow_tripdata_{label}.parquet"
        if download_file(url, destination):
            labels.append(label)
        if len(labels) == months:
            break

    if len(labels) < months:
        raise RuntimeError(f"Unable to download {months} months of yellow taxi data, only found {len(labels)}")

    if not download_file(ZONE_LOOKUP_URL, output_dir / "taxi_zone_lookup.csv"):
        raise RuntimeError("Unable to download taxi zone lookup file")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Fetch free NYC Taxi public data")
    parser.add_argument(
        "--months",
        type=int,
        default=2,
        help="How many completed months to download",
    )
    parser.add_argument(
        "--output-dir",
        default="data/raw",
        help="Destination directory for downloaded raw files",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    fetch_raw_data(output_dir=Path(args.output_dir), months=args.months)


if __name__ == "__main__":
    main()
