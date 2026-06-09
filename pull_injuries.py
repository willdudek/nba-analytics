import pandas as pd
import duckdb
import os
from datetime import datetime, timedelta
from nbainjuries import injury

# Game dates to pull — one representative time per date
# NBA injury reports are typically filed by 5pm ET day before
SEASONS = {
    '2022-23': ('2022-10-18', '2023-04-09'),
    '2023-24': ('2023-10-24', '2024-04-14'),
    '2024-25': ('2024-10-22', '2025-04-13'),
    '2025-26': ('2025-10-28', '2026-04-12'),
}

def get_game_dates(start_str, end_str):
    start = datetime.strptime(start_str, '%Y-%m-%d')
    end = datetime.strptime(end_str, '%Y-%m-%d')
    dates = []
    current = start
    while current <= end:
        dates.append(current)
        current += timedelta(days=1)
    return dates

all_records = []

for season, (start, end) in SEASONS.items():
    print(f"\nPulling {season}...")
    dates = get_game_dates(start, end)
    season_count = 0

    for date in dates:
        report_time = datetime(date.year, date.month, date.day, 17, 30)
        try:
            df = injury.get_reportdata(report_time, return_df=True)
            if df is not None and len(df) > 0:
                df['season'] = season
                all_records.append(df)
                season_count += len(df)
        except Exception:
            # No report for this date — skip silently
            pass

    print(f"  {season}: {season_count} records")

if not all_records:
    print("No data retrieved.")
else:
    final_df = pd.concat(all_records, ignore_index=True)
    final_df.columns = [c.lower().replace(' ', '_') for c in final_df.columns]

    print(f"\nTotal records: {len(final_df)}")
    print(f"Columns: {final_df.columns.tolist()}")

    token = os.environ.get('MOTHERDUCK_TOKEN')
    if not token:
        raise ValueError("MOTHERDUCK_TOKEN not set")

    conn = duckdb.connect('md:my_db')
    conn.execute("DROP TABLE IF EXISTS nba_injuries")
    conn.execute("CREATE TABLE nba_injuries AS SELECT * FROM final_df")
    count = conn.execute("SELECT COUNT(*) FROM nba_injuries").fetchone()[0]
    conn.close()

    print(f"Loaded {count} rows into nba_injuries")
    print("Done.")