# NBA Analytics — MotherDuck + Claude

Exploratory NBA player analytics built with DuckDB/MotherDuck as the query layer and Claude Desktop (via MCP) for analysis and visualization. Data covers three seasons: 2022-23, 2023-24, 2024-25.

## Stack

- **Data**: Basketball Reference (3 seasons of player stats)
- **Database**: [MotherDuck](https://motherduck.com) (cloud DuckDB)
- **Queries**: DuckDB SQL
- **AI layer**: Claude Desktop connected to MotherDuck via MCP

## Data

Raw data lives in MotherDuck (`my_db`):

| Table | Description |
|-------|-------------|
| `nba_2023` | 2022-23 season player stats |
| `nba_2024` | 2023-24 season player stats |
| `nba_2025` | 2024-25 season player stats |
| `nba_player_stats` | Combined table with a `season` column |

**Note on deduplication**: Basketball Reference includes a separate row per team for traded players. All queries use `ROW_NUMBER() OVER (PARTITION BY Player, season ORDER BY G DESC)` to keep only the row with the most games played.

## Analyses

### Dive 1 — Year-over-Year Player Trends
[`sql/dive_1_yoy_trends.sql`](sql/dive_1_yoy_trends.sql) · [Live Dive](https://app.motherduck.com/dives/18cf253d-6489-4756-9781-9857eeca55a3)

PPG, eFG%, and assists for players who appeared in all 3 seasons, displayed side by side with a 3-year PPG change column. Interactive version includes position filter and biggest risers/fallers tab.

### Dive 2 — 3-Point % Year Over Year
[`sql/dive_2_3pt_yoy.sql`](sql/dive_2_3pt_yoy.sql) · [Live Dive](https://app.motherduck.com/dives/5cae9f62-9e9e-4758-be55-58e9743b143a)

3P% trend across all 3 seasons for the top 10 shooters in 2024-25 (min. 20 GP, 15 MPG, 3 attempts/game). Interactive version shows one line per player with hover to surface per-season attempt counts.

### Dive 3 — Shooting Profile by Position
[`sql/dive_3_shooting_profile.sql`](sql/dive_3_shooting_profile.sql) · [Live Dive](https://app.motherduck.com/dives/a842b4b2-2433-42c3-8f43-121b8cbf3611)

3-point attempt rate vs 3P% efficiency by position and season. Surfaces catch-and-shoot specialists, volume shooters, and positional trends. Interactive version is filtered to PG/SG and includes a hustle index (ORB + STL + BLK) YoY tab.

## Running the Queries

Connect to MotherDuck and run any `.sql` file directly:

```bash
duckdb "md:" < sql/dive_1_yoy_trends.sql
```

Or open in Claude Desktop with MotherDuck MCP connected and paste the query.
