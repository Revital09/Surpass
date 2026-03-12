# Surpass - Junior Data Architect Take-Home Assignment

End-to-End data engineering pipeline analyzing vehicle data from Israel's Ministry of Transport open dataset.

---

## Project Overview

This project simulates a real-world data engineering workflow:

```
API → Raw Data (mrr_fct) → Cleaned DWH → Enriched Analytics → Business Insights
```

**Data Source:** [data.gov.il – Private and Commercial Vehicles](https://data.gov.il/he/datasets/ministry_of_transport/private-and-commercialvehicles/053cea08-09bc-40ec-8f7a-156f0677aff3)  
**Total Records:** ~4,095,609 vehicles  
**Database:** PostgreSQL

---

## Project Structure

```
SURPASS/
│
├── API Data Extraction/
│   ├── extract_vehicles.py        # Part A - API extraction with pagination
│   └── offset_checkpoint.txt      # Checkpoint for resuming extraction
│
├── DWH/
│   ├── create_mrr_fct.sql         # Creates mrr_fct schema and table
│   ├── load_raw_to_db.py          # Loads CSV into mrr_fct.vehicle
│   ├── dwh_schema.sql             # Creates dwh schema and table (dwh_schema.sql)
│   ├── dwh_procedure.sql          # Cleans and loads data from mrr_fct to dwh
│   ├── enrich_dwh.sql             # Adds enriched columns + indexes
│   └── enrichment_validation.csv  # NULL counts and distribution per enriched field
│
├── Dashboard/
│   ├── generate_dashboard.py      # Part D – generates all 4 charts
│   ├── chart_market_share.png
│   ├── chart_fleet_age.png
│   ├── chart_pollution_trend.png
│   └── chart_fuel_evolution.png
│
├── .env                           # Environment variables (not committed)
├── .gitignore
└── README.md
```

---

### Dataset Note

The raw file `mrr_fct_vehicle.csv` is not included in this repository because it exceeds GitHub's file size limit.
To reproduce the pipeline, generate it by running:

```bash
python "API Data Extraction/extract_vehicles.py"
```

##  Setup Instructions

### 1. Prerequisites

- Python 3.10+
- PostgreSQL 17
- PyCharm (Python)
- DataGrip (SQL)

### 2. Clone the Repository

```bash
git clone https://github.com/Revital09/Surpass-Home_Assignment.git
cd Surpass-Home_Assignment
```

### 3. Install Python Dependencies

```bash
pip install requests pandas sqlalchemy psycopg2-binary python-dotenv matplotlib
```

### 4. Configure Environment Variables

Create a `.env` file in the project root:

```env
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=surpass_project
```

### 5. Set Up the Database

Create the database in PostgreSQL:

```sql
CREATE DATABASE surpass_project;
```

Then run the SQL files in this order using DataGrip:

```
1. DWH/create_mrr_fct.sql     → creates mrr_fct schema + table
2. DWH/dwh_schema.sql         → creates dwh schema + table
```

---

## Running the Pipeline

### Part A – Extract API Data

```bash
python "API Data Extraction/extract_vehicles.py"
```

- Fetches all ~4M records from data.gov.il with pagination (limit=10,000)
- Supports resume via checkpoint file
- Saves to `mrr_fct_vehicle.csv` (all fields as text)

### Part A → B – Load Raw Data to DB

```bash
python DWH/load_raw_to_db.py
```

- Truncates `mrr_fct.vehicle` before loading (prevents duplicates)
- Loads CSV in chunks of 50,000 rows

### Part B – Clean and Load to DWH

Run in DataGrip:

```
DWH/dwh_procedure.sql → CALL dwh.load_vehicle();
```

- Converts types (INTEGER, DATE, VARCHAR)
- Handles NULLs: empty strings, "null", "NULL", "None" → SQL NULL
- Validates `shnat_yitzur` between 1900–2026
- Trims whitespace from all text fields

### Part C – Enrich DWH

Run in DataGrip:

```
DWH/enrich_dwh.sql
```

Adds 8 enriched columns with indexes.

### Part D – Generate Dashboard

```bash
python Dashboard/generate_dashboard.py
```

Generates 4 charts as high-resolution PNG files.

---

##  Data Architecture

### mrr_fct.vehicle (Raw Layer)
- All 24 columns stored as `TEXT`
- No transformations — exact copy from API
- ~4,095,609 rows

### dwh.vehicle (Clean Layer)
- Optimized data types (INTEGER, DATE, VARCHAR)
- NULL handling and data validation applied
- 25 columns including `load_ts` timestamp

### dwh.vehicle – Enriched Columns

| Column | Type | Description |
|--------|------|-------------|
| `vehicle_age` | INTEGER | 2026 - shnat_yitzur |
| `age_category` | VARCHAR | New / Recent / Mature / Old |
| `years_since_registration` | INTEGER | Years since moed_aliya_lakvish |
| `is_first_owner` | BOOLEAN | years_since_registration < 1 |
| `license_status` | VARCHAR | Active / Expiring Soon / Expired / Unknown |
| `fuel_category` | VARCHAR | Gasoline / Diesel / Electric / Hybrid / Other |
| `pollution_level` | VARCHAR | Low / Medium / High / Very High |
| `manufacturer_region` | VARCHAR | Japanese / European / American / Korean / Chinese / Other |

---

## Dashboard Charts

| Chart | Type | Insight |
|-------|------|---------|
| Market Share | Horizontal Bar | Top 15 manufacturers with % share |
| Fleet Age Distribution | Bar Chart | Distribution across age categories |
| Environmental Trend | Stacked Area | Pollution levels over production years (2000+) |
| Fuel Type Evolution | Stacked Bar | Fuel distribution by 5-year periods |

---

## Key Assumptions

- `moed_aliya_lakvish` format is `YYYY-M` (year-month without day) → treated as 1st of month for date calculations
- `shnat_yitzur` values outside 1900–2026 are set to NULL
- Manufacturer region classification is based on Hebrew brand names in `tozeret_nm`
- `pollution_level` NULL (~425K rows) reflects vehicles without `kvutzat_zihum` classification
- `years_since_registration` NULL (~269K rows) reflects vehicles with missing `moed_aliya_lakvish`

---

##  Tech Stack

| Tool | Purpose |
|------|---------|
| Python 3.12 | Data extraction, loading, visualization |
| PostgreSQL 17 | Database |
| pandas | Data manipulation |
| SQLAlchemy + psycopg2 | DB connection |
| matplotlib | Chart generation |
| DataGrip | SQL development |
| PyCharm | Python development |