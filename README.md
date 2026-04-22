# SQLMesh NYC Taxi Showcase

A production-style SQLMesh demo using a free public dataset (NYC TLC yellow taxi trip records), with layered models, audits, tests, macros, and GitHub Actions automation.

## Public raw data source

- Yellow trip parquet files: <https://d37ci6vzurychx.cloudfront.net/trip-data/>
- Taxi zone lookup table: <https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv>

## SQLMesh features showcased

- DuckDB gateway and SQLMesh project configuration
- Layered modeling (`raw` -> `staging` -> `intermediate` -> `marts`)
- Multiple model kinds:
  - `FULL` models (`raw_*`, `stg_taxi_zones`, `int_trip_enriched`, `fct_yellow_trip_daily`)
  - `INCREMENTAL_BY_TIME_RANGE` models (`stg_yellow_trips`, `fct_payment_type_daily`)
  - `SEED` model (`seed_payment_type_map`)
- Custom Python macro (`@safe_divide`)
- Custom SQL audits (`assert_non_negative_fare`, `assert_positive_trip_duration`)
- SQLMesh YAML model tests (`tests/test_fct_yellow_trip_daily.yaml`)
- Automated `sqlmesh test` + `sqlmesh plan --auto-apply` in GitHub Actions

## Repository layout

- `config.yaml`: SQLMesh project and DuckDB gateway configuration
- `scripts/fetch_nyc_taxi_data.py`: idempotent raw data downloader
- `models/raw/`: external-source ingestion models
- `models/staging/`: cleaned and typed staging models
- `models/intermediate/`: reusable business logic models
- `models/marts/`: fact tables for analytics
- `models/seeds/`: SQLMesh seed model definitions
- `macros/`: reusable SQLMesh macro definitions
- `audits/`: custom SQLMesh audits
- `seeds/`: static seed files
- `tests/`: Python tests + SQLMesh tests
- `.github/workflows/sqlmesh.yml`: CI/CD automation

## Local setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install sqlmesh duckdb pytest
```

## Run locally

```bash
export SQLMESH_HOME="$(pwd)/.sqlmesh_home"
python scripts/fetch_nyc_taxi_data.py --months 2
pytest -q
sqlmesh test
sqlmesh plan --auto-apply
```

## What gets built

- `taxi.raw_yellow_trips`
- `taxi.raw_taxi_zones`
- `taxi.stg_yellow_trips`
- `taxi.stg_taxi_zones`
- `taxi.int_trip_enriched`
- `taxi.fct_yellow_trip_daily`
- `taxi.fct_payment_type_daily`
- `taxi.seed_payment_type_map`

## Publishing to GitHub

Suggested repo name: `sqlmesh-nyc-taxi-showcase`

1. Create a new GitHub repository (or use `gh repo create sqlmesh-nyc-taxi-showcase --public --source=. --remote=origin`).
2. Push this project.
3. Ensure default branch is `main`.
4. GitHub Actions automatically runs on push/PR and daily schedule.

No cloud warehouse credentials are needed because DuckDB runs fully in CI.

graph TD
    subgraph "Development & CI/CD (Zero Cost)"
        A[Developer Commits Code] -->|Pushes PR| B(GitHub Actions Runner)
        B -->|Runs 'sqlmesh test'| C[(DuckDB - Ephemeral)]
        C --> D{Tests Pass?}
        D -->|Yes| E[Merge to Main]
        D -->|No| F[Block PR]
    end

    subgraph "Production (Paid Compute)"
        E -->|Triggers Deployment| G(GitHub Actions Cron / Prod Job)
        G -->|Runs 'sqlmesh plan'| H[(Postgres / Snowflake)]
        H --> I[Updated Data Marts]
    end
    
    style C fill:#f9f,stroke:#333,stroke-width:2px
    style H fill:#bbf,stroke:#333,stroke-width:2px
