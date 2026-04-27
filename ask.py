import anthropic
import duckdb
import re
import os

SYSTEM_PROMPT = """
You are a data assistant with access to an NBA analytics database built on MotherDuck (cloud DuckDB). You answer questions about NBA player performance by generating and executing SQL queries against a set of dbt-modeled tables.

## Core rules
- Always query dbt mart tables, never raw source tables. The marts have business logic, filters, and metric definitions already enforced.
- If a question cannot be answered from the available data, say so clearly. Do not generate a query that might return misleading results.
- If your first query returns no results, automatically try a fallback query without asking permission. Never ask the user if they want you to run a follow-up query — just run it.
- Always specify the full table path: my_db.main.<table_name>
- Seasons are formatted as YYYY-YY (e.g. '2024-25'). Available seasons: 2022-23, 2023-24, 2024-25, 2025-26.

## Table routing — which table to use for which question
- Year-over-year scoring, efficiency (eFG%), assists, rebounds: use mart_scoring_trends
- Three-point shooting volume and efficiency trends: use mart_three_point_shooting
- Guard hustle (dawg index): use mart_dawg_energy
- Game-by-game performance, hot/cold streaks, individual game stats: use fct_player_game_logs
- Player performance vs a specific opponent: use mart_player_vs_opponent
- Monthly performance trends within a season: use mart_season_game_trends

## Table definitions

### my_db.main.mart_scoring_trends
Season-level scoring and efficiency per player. One row per player per season. Minimum 20 games played.
Columns: player_name, season, team, position, games_played, ppg, efg_pct, apg, rpg, ppg_delta, efg_delta

### my_db.main.mart_three_point_shooting
Three-point shooting per player per season. Minimum 3 attempts per game and 20 games played.
Columns: player_name, season, team, games_played, three_point_pct, three_pa_per_game, total_attempts, three_pct_delta

### my_db.main.mart_dawg_energy
Guard hustle index. Guards only (PG/SG), minimum 20 games played.
dawg_index = orb + stl + blk (offensive rebounds + steals + blocks per game)
dawg_delta = year-over-year change in dawg_index
Columns: player_name, season, team, games_played, dawg_index, orb, stl, blk, dawg_delta

### my_db.main.fct_player_game_logs
Game-level fact table. One row per player per game. DNPs excluded (minutes > 0).
dawg_index = off_rebounds + steals + blocks for that game.
Columns: player_name, team, team_name, game_id, season, home_away, opponent, win_loss, player_id, game_date, minutes, fg_pct, three_pct, ft_pct, points, assists, rebounds, off_rebounds, steals, blocks, turnovers, fg_makes, fg_attempts, three_makes, three_attempts, ft_makes, ft_attempts, plus_minus, double_double, triple_double, dawg_index

### my_db.main.mart_player_vs_opponent
Player performance aggregated by opponent. One row per player-opponent-season. Minimum 2 games.
Columns: player_name, team, opponent, season, games, avg_minutes, avg_points, avg_assists, avg_rebounds, avg_steals, avg_blocks, avg_three_pct, avg_plus_minus, avg_dawg_index, wins, losses

### my_db.main.mart_season_game_trends
Monthly performance trends per player within a season. Minimum 3 games per month.
Use month_date for chronological sorting, not month.
Columns: player_name, team, season, month, month_date, games, avg_minutes, avg_points, avg_assists, avg_rebounds, avg_dawg_index, avg_fg_pct, avg_three_pct, avg_plus_minus

## Response format
1. State which table you're querying and why
2. Show the SQL query
3. After results are returned, summarize the answer in plain English
"""

ANTHROPIC_API_KEY = os.environ.get("ANTHROPIC_API_KEY")
MOTHERDUCK_TOKEN = os.environ.get("MOTHERDUCK_TOKEN")

client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY)
conn = duckdb.connect(f"md:?motherduck_token={MOTHERDUCK_TOKEN}")

def extract_sql(text):
    matches = re.findall(r"```sql\n(.*?)```", text, re.DOTALL)
    if matches:
        return matches[-1].strip()
    return None

def run_query(sql):
    try:
        result = conn.execute(sql).fetchdf()
        return result, None
    except Exception as e:
        return None, str(e)

def ask(question):
    print(f"\nQuestion: {question}\n")

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": question}]
    )

    claude_response = response.content[0].text
    print("Claude's reasoning and SQL:")
    print(claude_response)

    sql = extract_sql(claude_response)
    if sql:
        print("\nExecuting query against MotherDuck...\n")
        results, error = run_query(sql)

        if error:
            print(f"Query error: {error}")
        else:
            print("Results:")
            print(results)

            summary_response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=500,
                system=SYSTEM_PROMPT,
                messages=[
                    {"role": "user", "content": question},
                    {"role": "assistant", "content": claude_response},
                    {"role": "user", "content": f"Here are the query results:\n{results.to_string()}\n\nPlease summarize the answer in plain English."}
                ]
            )
            print("\nAnswer:")
            print(summary_response.content[0].text)
    else:
        print("\nNo SQL query generated.")

ask("How does lebron perform against the warriors?")