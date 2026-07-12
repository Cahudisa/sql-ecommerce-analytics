"""
Bronze layer ingestion — loads the 9 Olist CSV files into the `raw` schema
of the local PostgreSQL instance, as-is (no transformations).

Usage:
    python ingestion/load_raw.py
"""

from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
DB_URL = "postgresql+psycopg2://olist:olist_local_dev@localhost:5432/ecommerce"
RAW_DIR = Path(__file__).resolve().parents[1] / "data" / "raw"
SCHEMA = "raw"

# CSV file -> target table name (kept close to the source names)
FILES = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "product_category_translation",
}

CHUNKSIZE = 50_000  # keeps memory usage low for the larger files


def main() -> None:
    engine = create_engine(DB_URL)

    # Create the raw schema if it doesn't exist yet
    with engine.begin() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA}"))

    for filename, table in FILES.items():
        path = RAW_DIR / filename
        if not path.exists():
            print(f"[SKIP] {filename} not found in {RAW_DIR}")
            continue

        print(f"[LOAD] {filename} -> {SCHEMA}.{table} ...", end=" ", flush=True)
        rows = 0
        for i, chunk in enumerate(pd.read_csv(path, chunksize=CHUNKSIZE)):
            chunk.to_sql(
                table,
                engine,
                schema=SCHEMA,
                if_exists="replace" if i == 0 else "append",
                index=False,
                method="multi",
                chunksize=5_000,
            )
            rows += len(chunk)
        print(f"done ({rows:,} rows)")

    # Quick sanity check: row counts per table
    print("\nRow counts in schema 'raw':")
    with engine.connect() as conn:
        for table in FILES.values():
            count = conn.execute(
                text(f"SELECT COUNT(*) FROM {SCHEMA}.{table}")
            ).scalar()
            print(f"  {table:<32} {count:>10,}")


if __name__ == "__main__":
    main()
