import json
import os

MANIFEST_PATH = "nba_dbt/target/manifest.json"
CATALOG_PATH = "nba_dbt/target/catalog.json"
OUTPUT_PATH = "system_prompt.txt"

# Models to include in the system prompt — staging models excluded,
# mart_monthly_player_averages excluded (redundant with mart_season_game_trends)
MODELS_TO_INCLUDE = [
    "mart_scoring_trends",
    "mart_three_point_shooting",
    "mart_dawg_energy",
    "fct_player_game_logs",
    "mart_player_vs_opponent",
    "mart_season_game_trends",
    "mart_player_injury_history",
    "mart_team_injury_profile",
    "mart_player_injury_performance",
]

# Routing rules — written once here, not auto-generated
ROUTING_RULES = """## Table routing — which table to use for which question
- Year-over-year scoring, efficiency (eFG%), assists, rebounds: use mart_scoring_trends
- Three-point shooting volume and efficiency trends: use mart_three_point_shooting
- Guard hustle (dawg index): use mart_dawg_energy
- Game-by-game performance, hot/cold streaks, individual game stats: use fct_player_game_logs
- Player performance vs a specific opponent: use mart_player_vs_opponent
- Monthly performance trends within a season: use mart_season_game_trends
- Player injury history, games missed, injury types by season: use mart_player_injury_history
- Team injury availability on a specific date, matchup injury context: use mart_team_injury_profile
- Player performance before and after returning from injury: use mart_player_injury_performance
"""

def load_json(path):
    with open(path) as f:
        return json.load(f)

def build_prompt():
    manifest = load_json(MANIFEST_PATH)
    catalog = load_json(CATALOG_PATH)

    lines = []

    # Header
    lines.append("""You are a data assistant with access to an NBA analytics database built on MotherDuck (cloud DuckDB). You answer questions about NBA player performance by generating and executing SQL queries against a set of dbt-modeled tables.

## Core rules
- Always query dbt mart tables, never raw source tables. The marts have business logic, filters, and metric definitions already enforced.
- If a question cannot be answered from the available data, say so clearly. Do not generate a query that might return misleading results.
- If your first query returns no results, automatically try a fallback query without asking permission. Never ask the user if they want you to run a follow-up query — just run it.
- Always specify the full table path: my_db.main.<table_name>
- Seasons are formatted as YYYY-YY (e.g. '2024-25'). Available seasons: 2022-23, 2023-24, 2024-25, 2025-26.
- You are in a multi-turn conversation. You have access to the full conversation history. Use prior questions and answers as context when interpreting follow-up questions.
""")

    lines.append(ROUTING_RULES)
    lines.append("## Table definitions\n")

    for model_name in MODELS_TO_INCLUDE:
        node_key = f"model.nba_dbt.{model_name}"

        # get description from manifest
        node = manifest.get("nodes", {}).get(node_key, {})
        model_description = node.get("description", "").strip()
        manifest_columns = node.get("columns", {})

        # get column types from catalog
        catalog_node = catalog.get("nodes", {}).get(node_key, {})
        catalog_columns = catalog_node.get("columns", {})

        lines.append(f"### my_db.main.{model_name}")
        if model_description:
            lines.append(model_description)

        # build column list combining types from catalog and descriptions from manifest
        col_lines = []
        for col_name, col_meta in catalog_columns.items():
            col_type = col_meta.get("type", "")
            manifest_col = manifest_columns.get(col_name, {})
            col_description = manifest_col.get("description", "").strip()
            if col_description:
                col_lines.append(f"  - {col_name} ({col_type}): {col_description}")
            else:
                col_lines.append(f"  - {col_name} ({col_type})")

        if col_lines:
            lines.append("Columns:")
            lines.extend(col_lines)

        lines.append("")

    lines.append("""## Response format
1. State which table you're querying and why
2. Show the SQL query
3. After results are returned, summarize the answer in plain English
""")

    prompt = "\n".join(lines)

    with open(OUTPUT_PATH, "w") as f:
        f.write(prompt)

    print(f"System prompt written to {OUTPUT_PATH}")
    print(f"Models included: {len(MODELS_TO_INCLUDE)}")
    print(f"Prompt length: {len(prompt)} characters")

if __name__ == "__main__":
    build_prompt()
