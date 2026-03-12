# Surpass - Junior Data Architect Take-Home Assignment

End-to-End data engineering pipeline for analyzing vehicle data from Israel's Ministry of Transport open dataset.

---

## Project Overview

This project simulates a real-world data engineering workflow:

```
API → Raw Data (mrr_fct) → Cleaned DWH → Enriched Analytics → Business Insights
```
The pipeline extracts vehicle data from the Israeli Ministry of Transport open dataset, processes and cleans the data in PostgreSQL, enriches it with analytical fields, and generates business intelligence dashboards.

**Data Source:** https://data.gov.il/api/3/action/datastore_search?resource_id=053cea08-09bc-40ec-8f7a-156f0677aff3  
**Total Records:** ~4,095,108 vehicles  
**Database:** PostgreSQL

---

## Project Structure

```
SURPASS/
│
├── API Data Extraction/
│   ├── extract_vehicles.py     
│   ├── offset_checkpoint.txt     
│   └── load_raw_to_db.py          
│
│
├── DWH/
│   ├── dwh_schema.sql            
│   ├── dwh_procedure.sql       
│   ├── enrich_dwh.sql           
│   ├── validation_queries.sql
│   └── enrichment_validation.csv  
│
├── Dashboard/
│   ├── generate_dashboard.py    
│   ├── chart_market_share.png
│   ├── chart_fleet_age.png
│   ├── chart_pollution_trend.png
│   └── chart_fuel_evolution.png
│
├── .env                      
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

### 4. Environment Variables

Create a `.env` file in the project root:

```env
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=surpass_project
```
- These variables are used by:`load_raw_to_db.py`,`generate_dashboard.py`


### 5. Create Database

Create the database in PostgreSQL:

```sql
CREATE DATABASE surpass_project;
```

Run the pipeline in the following order:

#### Create Raw Schema
```
 DWH/dwh_schema.sql       
```
- Creates:
mrr_fct.vehicle (raw ingestion table), dwh.vehicle (clean warehouse table)

## Running the Pipeline

### Part A - Extract API Data

```bash
python "API Data Extraction/extract_vehicles.py"
```

- Fetches all ~4M records from data.gov.il with pagination (limit=10,000)
- Supports resume via checkpoint file
- Saves to `mrr_fct_vehicle.csv` (all fields as text)

### Part A → B - Load Raw Data to DB

```bash
python API Data Extraction/load_raw_to_db.py
```

- Cleans `mrr_fct.vehicle` before loading (prevents duplicates)
- Loads CSV in chunks of 50,000 rows

### Part B - Clean and Load to DWH

Run in DataGrip:

```
DWH/dwh_procedure.sql 
```

- Converts types (INTEGER, DATE, VARCHAR)
- Handles NULLs: empty strings, "null", "NULL", "None" → SQL NULL
- Validates `shnat_yitzur` between 1900–2026
- Trims whitespace from all text fields

### Part C - Enrich DWH

Run in DataGrip:

```
DWH/enrich_dwh.sql
```

Adds 6 enriched columns with indexes:
- age_category
- fuel_category
- is_first_owner
- license_status
- manufacturer_region
- pollution_level


### Part D – Generate Dashboard

```bash
python Dashboard/generate_dashboard.py
```

Generates 4 charts as high-resolution PNG files:
- Chart 1: Market Share Analysis
- Chart 2: Fleet Age Distribution
- Chart 3: Environmental Trend
- Chart 4: Fuel Type Evolution

---

##  Data Architecture

### mrr_fct.vehicle (Raw Layer)
Raw ingestion table storing the exact API output.
- All 24 columns stored as `TEXT`
- No transformations - exact copy from API
- ~4,095,108 rows

### dwh.vehicle (Clean Layer)
- Optimized data types (INTEGER, DATE, VARCHAR)
- NULL handling and data validation applied
- 25 columns including `load_ts` timestamp

### dwh.vehicle - Enriched Columns

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

| Chart | Type           | Insight |
|-------|----------------|---------|
| Market Share | Horizontal Bar | Top 15 manufacturers with % share |
| Fleet Age Distribution | Histogram      | Vehicle age distribution grouped into age categories (New, Recent, Mature, Old) | |
| Environmental Trend | Stacked Area   | Pollution levels over production years (2000+) |
| Fuel Type Evolution | Stacked Bar    | Fuel distribution by 5-year periods |

## Key Insights

- The largest portion of vehicles belongs to the **Mature (8–15 years)** category, indicating that most vehicles in the fleet are mid-aged rather than new.
- **Toyota, Hyundai, and Kia dominate the market share**, representing the largest manufacturers in the Israeli vehicle fleet.
- Environmental trends show an **increase in vehicles with lower pollution levels in recent production years**, reflecting improvements in vehicle emissions standards.
- **Electric and hybrid vehicles have grown rapidly after 2020**, indicating a transition toward cleaner energy sources in the automotive market.
---

## Key Assumptions
- `moed_aliya_lakvish` appears in `YYYY-M` format (year and month only).
  For date calculations it was converted to a full DATE using the first day of the month.

- `shnat_yitzur` values outside the range 1900–2026 were considered invalid and replaced with NULL.

- Manufacturer names (`tozeret_nm`) were standardized using rule-based normalization.
  Variations, aliases, and alternate spellings were mapped into a single canonical manufacturer name.

- Manufacturer region was derived from the standardized manufacturer name (`tozeret_nm`)
  using a rule-based mapping into `Japanese`, `European`, `American`, `Korean`, `Chinese`, or `Other`.

- Source fuel values were grouped into broader analytical categories:
  `Gasoline`, `Diesel`, `Electric`, `Hybrid`, and `Other`.
  Mixed fuel types such as `חשמל/בנזין` and `חשמל/דיזל` were classified as `Hybrid`.

- Some vehicles (~425K rows) do not contain `kvutzat_zihum` values in the source dataset,
  resulting in NULL `pollution_level`.

- Vehicles with missing `moed_aliya_lakvish` (~269K rows) cannot have
  `years_since_registration` calculated.
---

##  Tech Stack

| Tool | Purpose |
|------|---------|
| Python 3.12 | Data extraction, loading, visualization |
| PostgreSQL 17 | Database |
| pandas | Data manipulation |
| SQLAlchemy + psycopg2 | DB connection |
| matplotlib | Chart generation |
| requests | API extraction |
| python-dotenv | Environment variable management |
| DataGrip | SQL development |
| PyCharm | Python development |