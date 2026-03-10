import pandas as pd
df = pd.read_csv("mrr_fct_vehicle.csv", encoding="utf-8-sig")
print(df.shape)        # צריך להיות ~4,095,110 שורות
print(df.dtypes)       # הכל צריך להיות object/string
print(df.head(3))      # לראות שהנתונים נראים הגיוני
print(df.columns.tolist())  # לראות את שמות העמודות