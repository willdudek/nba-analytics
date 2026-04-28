# NBA Analytics — Modern Data Stack Portfolio Project

A personal project built to explore modern data stack architecture and AI tooling hands-on — specifically how AI fits into each layer of a data platform, from development tooling to natural language querying. Uses NBA player data as the domain; the basketball framing is intentional but incidental.

The real artifact is an end-to-end pipeline: raw sources → modeled, tested, documented data layer → live BI dashboard → natural language interface powered by the Claude API.

**Live dashboard:** [willdudek.github.io/nba-analytics](https://willdudek.github.io/nba-analytics)

---

## Stack

| Layer | Tool | Notes |
|-------|------|-------|
| Data warehouse | MotherDuck (cloud DuckDB) | Serverless, fast, native MCP support |
| Transformation | dbt Core | Version-controlled SQL, testing, documentation |
| BI / dashboard | Evidence.dev | SQL-first, open source, deploys as static files |
| AI interface | Claude API | Natural language querying over dbt-modeled data |
| Development | Claude Desktop + MCP | Interactive data exploration and AI-assisted development |
| CI/CD | GitHub Actions + GitHub Pages | Automated deployment on push to main |

---

## Architecture

```
Data Sources
├── Basketball Reference CSVs (season-level stats, 2022-23 through 2025-26)
└── NBA Stats API (game-level logs via pull_game_logs.py)
        ↓
MotherDuck (cloud DuckDB)
    Raw tables: nba_player_stats, nba_game_logs
        ↓
dbt Core
    Staging layer — cleaning, deduplication, standardization
    ├── stg_nba_player_stats
    └── stg_nba_game_logs
        ↓
    Mart layer — business logic, metric definitions
    ├── mart_scoring_trends
    ├── mart_three_point_shooting
    ├── mart_dawg_energy
    ├── fct_player_game_logs
    ├── mart_player_vs_opponent
    └── mart_season_game_trends
        ↓
Two consumers
├── Evidence.dev dashboard → GitHub Pages
└── Claude API natural language interface (ask.py)
```

---

## Project Roadmap

**Phase 1 — Foundation**
Connected MotherDuck to Claude Desktop via MCP. Loaded raw data, explored interactively using natural language queries. First hands-on look at MCP as a connection layer between an AI and a live database.

**Phase 2 — Evidence Dashboard**
Built a live dashboard using Evidence.dev — SQL-first, open source, compiles to static files. Deployed via GitHub Actions to GitHub Pages with automated CI/CD. Hit the limits of Evidence dynamic filtering and cross-query interactivity, which informed the decision to build a proper AI interface in Phase 5.

**Phase 3 — dbt Modeling**
Replaced hand-written views with a proper dbt project. Staging → mart architecture, 14 passing data quality tests, caught and fixed real data issues. Established main/dev Git branching workflow. Before: logic in hand-written views, no tests, no reproducibility. After: version-controlled SQL, full lineage, clone and run.

**Phase 4 — Data Expansion + Semantic Layer**
Added 2025-26 season data and game-level data from the NBA Stats API. Built three new models including a grain-level fact table. Made a deliberate decision to implement documentation-as-semantic-layer over a formal semantic layer tool — the right call at this scale with technical consumers, but would revisit when non-technical users need to query directly or when multiple tools need metric definitions enforced consistently.

**Phase 5 — Natural Language Interface**
Built a Python script using the Claude API. Accepts a natural language question, generates SQL with dbt schema documentation as system prompt context, executes against MotherDuck, returns a plain English answer. Built and ran a 10-question eval set across easy/medium/hard tiers to validate accuracy and inform system prompt and semantic layer refinements.

---

## Key Decisions

**dbt over hand-written views**
Before dbt, transformation logic lived in hand-written MotherDuck views — no tests, no documentation, no reproducibility. dbt replaced that with version-controlled SQL, a staging → mart architecture, and data quality tests that caught real issues. The before/after is concrete: clone the repo, run dbt run, the entire data layer rebuilds from scratch.

**Evidence over a traditional BI tool**
Evidence is SQL-first and open source — every query is a version-controlled file, every dashboard deploys as static HTML. The tradeoff is limited dynamic filtering and no GUI for non-technical users. Worth it for a technical portfolio project where Git-native workflow and AI-assisted development matter more than point-and-click.

**Documentation-as-semantic-layer**
Rather than implementing a formal semantic layer tool, metric definitions, business rules, and architectural guidance live in dbt schema.yml files. Precise enough to serve as LLM context in Phase 5 — the same documentation that a human reads in the dbt docs site is what Claude reads before generating SQL. Sufficient at this scale; would revisit with non-technical users or multiple tools needing consistent metric enforcement.

**Evaluation before shipping the AI interface**
Built a 10-question eval set across easy, medium, and hard tiers before calling Phase 5 done. Caught real issues — column name drift between documentation and actual tables, query extraction logic — that would have affected production behavior. Same rigor as data pipeline testing applied to an AI system.

---

*Data sources: Basketball Reference (season aggregates), NBA Stats API (game logs)*
