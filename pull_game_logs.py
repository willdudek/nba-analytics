import requests
import pandas as pd
import time

headers = {
    'Host': 'stats.nba.com',
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate, br',
    'x-nba-stats-origin': 'stats',
    'x-nba-stats-token': 'true',
    'Connection': 'keep-alive',
    'Referer': 'https://www.nba.com/',
    'Origin': 'https://www.nba.com',
}

seasons = ['2022-23', '2023-24', '2024-25', '2025-26']

all_logs = []

for season in seasons:
    print(f"Pulling {season}...")
    url = 'https://stats.nba.com/stats/playergamelogs'
    params = {
        'SeasonType': 'Regular Season',
        'Season': season,
        'LeagueID': '00'
    }
    
    try:
        response = requests.get(url, headers=headers, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        
        headers_list = data['resultSets'][0]['headers']
        rows = data['resultSets'][0]['rowSet']
        
        df = pd.DataFrame(rows, columns=headers_list)
        df['SEASON'] = season
        all_logs.append(df)
        print(f"  Got {len(df)} rows")
        time.sleep(2)
        
    except Exception as e:
        print(f"  Error: {e}")

final_df = pd.concat(all_logs, ignore_index=True)
final_df.to_csv('/Users/willdudek/Documents/nba-analytics/nba_game_logs.csv', index=False)
print(f"\nDone. Total rows: {len(final_df)}")
print(f"Columns: {list(final_df.columns)}")
