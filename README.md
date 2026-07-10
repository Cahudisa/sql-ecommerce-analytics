# SQL E-Commerce Analytics 🛒

> SQL-first analytics pipeline on the Olist Brazilian e-commerce dataset (100k orders, 9 relational tables): PostgreSQL + dbt + Power BI, following the medallion architecture (Bronze → Silver → Gold).

## 📌 Business Questions
- How does customer retention evolve by monthly cohort?
- Which customer segments matter most? (RFM segmentation)
- Which sellers and states have the worst late-delivery rates?
- What are the top products and sellers by revenue, ranked per category?
- How do average order value and revenue grow month over month?

## 🏗️ Architecture

```
Raw CSVs (Kaggle)
      │
      ▼
PostgreSQL (Docker)   → raw schema (Bronze)
      │
      ▼
dbt — staging models  → cleaning, casting, dedup (Silver)
      │
      ▼
dbt — marts           → cohorts, RFM, KPIs (Gold) + data quality tests
      │
      ▼
Power BI Dashboard    → executive report
```

## 📊 Data Source

| Dataset | Source |
|---|---|
| Brazilian E-Commerce Public Dataset by Olist (9 tables, ~100k orders) | [Kaggle — olistbr](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) |

> Raw CSV files are not included in this repo. Download them from Kaggle and place them in `data/raw/`.

## 🛠️ Stack

| Layer | Tools |
|---|---|
| Storage & Compute | PostgreSQL 16 (Docker) |
| Ingestion | Python (pandas, SQLAlchemy) |
| Transformation | dbt Core (SQL) |
| Data Quality | dbt tests |
| Documentation | dbt docs (lineage graph) |
| Business Intelligence | Power BI |
| Version Control | Git, GitHub |

## 📁 Project Structure

```
sql-ecommerce-analytics/
│
├── data/
│   └── raw/              ← Raw CSV files (not tracked by Git)
│
├── ingestion/
│   └── load_raw.py       ← Loads the 9 CSVs into the raw schema
│
├── dbt_project/
│   ├── models/staging/   ← Silver: cleaning, casting, dedup
│   ├── models/marts/     ← Gold: cohorts, RFM, delivery KPIs
│   └── tests/            ← Custom data quality tests
│
├── analysis/             ← Standalone advanced SQL queries (commented)
├── powerbi/              ← Power BI report (.pbix) + screenshots
├── docs/                 ← ERD and additional documentation
├── docker-compose.yml
└── README.md
```

## ⚙️ How to Run Locally

```bash
# 1. Clone the repo
git clone https://github.com/Cahudisa/sql-ecommerce-analytics.git
cd sql-ecommerce-analytics

# 2. Start PostgreSQL
docker compose up -d

# 3. Create and activate virtual environment
python -m venv venv
venv\Scripts\activate       # Windows
source venv/bin/activate    # Mac/Linux

# 4. Install dependencies
pip install -r requirements.txt

# 5. Download the Olist dataset from Kaggle and place the CSVs in data/raw/

# 6. Load raw data into PostgreSQL
python ingestion/load_raw.py

# 7. Run dbt transformations and tests
cd dbt_project
dbt run
dbt test
```

## 🚧 Status
Work in progress — currently in Phase 1 (Bronze layer: ingestion).

## 👤 Author
**Carlos Díaz** — Data Engineer
[GitHub](https://github.com/Cahudisa) · [Portfolio Project 1: AI Tech Landscape Pipeline](https://github.com/Cahudisa/ai-tech-landscape-pipeline)
