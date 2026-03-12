import pandas as pd
df = pd.read_csv("mrr_fct_vehicle.csv", encoding="utf-8-sig")
print(df.shape)
print(df.dtypes)
print(df.head(3))
print(df.columns.tolist())
