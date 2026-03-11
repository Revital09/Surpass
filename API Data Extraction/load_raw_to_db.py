import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

CSV_FILE = r"C:\Users\revit\PycharmProjects\SURPASS\API Data Extraction\mrr_fct_vehicle.csv"
CHUNKSIZE = 50000

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

print("Truncating mrr_fct.vehicle...")
with engine.connect() as conn:
    conn.execute(text("TRUNCATE TABLE mrr_fct.vehicle"))
    conn.commit()
print("Table cleared ")

print("Starting load into mrr_fct.vehicle...")

for i, chunk in enumerate(
    pd.read_csv(CSV_FILE, dtype=str, chunksize=CHUNKSIZE, encoding="utf-8-sig"),
    start=1
):
    chunk.to_sql(
        name="vehicle",
        con=engine,
        schema="mrr_fct",
        if_exists="append",
        index=False
    )
    print(f"Loaded chunk {i}")

print("Finished loading CSV into mrr_fct.vehicle")
