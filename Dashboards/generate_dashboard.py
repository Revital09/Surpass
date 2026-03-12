import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['axes.unicode_minus'] = False
from sqlalchemy import create_engine
from dotenv import load_dotenv

from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
env_path = BASE_DIR / "API Data Extraction" / ".env"

load_dotenv(env_path)

engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_NOTE = "Source: Israel Ministry of Transport | data.gov.il"

# CHART 1: Market Share
print("Generating Chart 1: Market Share...")

df1 = pd.read_sql("""
    SELECT tozeret_nm AS manufacturer, COUNT(*) AS vehicle_count
    FROM dwh.vehicle
    WHERE tozeret_nm IS NOT NULL
    GROUP BY tozeret_nm
    ORDER BY vehicle_count DESC
    LIMIT 15
""", engine)

# percentage within Top 15
df1['pct'] = df1['vehicle_count'] / df1['vehicle_count'].sum() * 100

fig, ax = plt.subplots(figsize=(14, 7))
bars = ax.barh(df1['manufacturer'], df1['vehicle_count'])

for i, (val, pct) in enumerate(zip(df1['vehicle_count'], df1['pct'])):
    ax.text(val + 1000, i, f'{val:,} ({pct:.1f}%)', va='center', fontsize=9)

ax.set_xlabel('Number of Vehicles', fontsize=12)
ax.set_title('Top 15 Manufacturers by Vehicle Count', fontsize=15, fontweight='bold', pad=15)
ax.invert_yaxis()
ax.set_xlim(0, df1['vehicle_count'].max() * 1.25)

fig.text(0.99, 0.01, SOURCE_NOTE, ha='right', fontsize=8, color='gray')

plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'chart_market_share.png'), dpi=300, bbox_inches='tight')
plt.close()

print("  chart_market_share.png saved ")


# CHART 2: Fleet Age Distribution
print("Generating Chart 2: Fleet Age Distribution...")

df2 = pd.read_sql("""
    SELECT vehicle_age
    FROM dwh.vehicle
    WHERE vehicle_age IS NOT NULL
""", engine)

bins = [0, 4, 8, 16, df2['vehicle_age'].max() + 1]
labels = ['New (0-3)', 'Recent (4-7)', 'Mature (8-15)', 'Old (16+)']

fig, ax = plt.subplots(figsize=(10, 6))

counts, bins, patches = ax.hist(
    df2['vehicle_age'],
    bins=bins,
    edgecolor='white'
)

ax.set_xticks([1.5, 5.5, 11.5, 20])
ax.set_xticklabels(labels)

ax.set_xlabel('Vehicle Age Category', fontsize=12)
ax.set_ylabel('Number of Vehicles', fontsize=12)
ax.set_title('Fleet Age Distribution', fontsize=15, fontweight='bold', pad=15)

ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f'{int(x):,}'))

fig.text(0.99, 0.01, SOURCE_NOTE, ha='right', fontsize=8, color='gray')

plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'chart_fleet_age.png'), dpi=300, bbox_inches='tight')
plt.close()

print("  chart_fleet_age.png saved ")


# CHART 3: Environmental Trend — Pollution Levels over Years
print("Generating Chart 3: Environmental Trend...")

df3 = pd.read_sql("""
    SELECT shnat_yitzur AS year, pollution_level, COUNT(*) AS vehicle_count
    FROM dwh.vehicle
    WHERE shnat_yitzur >= 2000
      AND pollution_level IS NOT NULL
    GROUP BY shnat_yitzur, pollution_level
    ORDER BY shnat_yitzur
""", engine)

df3_pivot = df3.pivot(index='year', columns='pollution_level', values='vehicle_count').fillna(0)
for col in ['Low', 'Medium', 'High', 'Very High']:
    if col not in df3_pivot.columns:
        df3_pivot[col] = 0
df3_pivot = df3_pivot[['Low', 'Medium', 'High', 'Very High']]

colors3 = ['#2ecc71', '#f1c40f', '#e67e22', '#e74c3c']
fig, ax = plt.subplots(figsize=(14, 7))
ax.stackplot(df3_pivot.index, df3_pivot.T, labels=df3_pivot.columns, colors=colors3, alpha=0.85)
ax.set_xlabel('Production Year', fontsize=12)
ax.set_ylabel('Number of Vehicles', fontsize=12)
ax.set_title('Pollution Levels Over Production Years (2000+)', fontsize=15, fontweight='bold', pad=15)
ax.legend(loc='upper left', fontsize=10)
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f'{int(x):,}'))
fig.text(0.99, 0.01, SOURCE_NOTE, ha='right', fontsize=8, color='gray')
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'chart_pollution_trend.png'), dpi=300, bbox_inches='tight')
plt.close()
print("  chart_pollution_trend.png saved ")

# CHART 4: Fuel Type Evolution by 5-Year Periods
print("Generating Chart 4: Fuel Evolution...")

df4 = pd.read_sql("""
    SELECT
        (shnat_yitzur / 5 * 5)::TEXT || '-' || (shnat_yitzur / 5 * 5 + 4)::TEXT AS period,
        fuel_category,
        COUNT(*) AS vehicle_count
    FROM dwh.vehicle
    WHERE shnat_yitzur >= 1990
      AND fuel_category IS NOT NULL
    GROUP BY period, fuel_category
    ORDER BY period
""", engine)

df4_pivot = df4.pivot(index='period', columns='fuel_category', values='vehicle_count').fillna(0)
df4_pct = df4_pivot.div(df4_pivot.sum(axis=1), axis=0) * 100

colors4 = {'Gasoline': '#e74c3c', 'Diesel': '#3498db',
           'Electric': '#2ecc71', 'Hybrid': '#f39c12', 'Other': '#95a5a6'}
plot_colors = [colors4.get(c, '#bdc3c7') for c in df4_pct.columns]

fig, ax = plt.subplots(figsize=(14, 7))
df4_pct.plot(kind='bar', stacked=True, ax=ax, color=plot_colors, edgecolor='white', linewidth=0.5)
ax.set_xlabel('5-Year Period', fontsize=12)
ax.set_ylabel('Percentage (%)', fontsize=12)
ax.set_title('Fuel Type Distribution by 5-Year Periods', fontsize=15, fontweight='bold', pad=15)
ax.legend(loc='upper left', bbox_to_anchor=(1, 1), fontsize=10)
ax.set_xticklabels(ax.get_xticklabels(), rotation=45, ha='right')
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f'{x:.0f}%'))
fig.text(0.99, 0.01, SOURCE_NOTE, ha='right', fontsize=8, color='gray')
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, 'chart_fuel_evolution.png'), dpi=300, bbox_inches='tight')
plt.close()
print("  chart_fuel_evolution.png saved ")

