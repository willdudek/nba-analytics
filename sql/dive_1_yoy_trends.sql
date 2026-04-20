-- =============================================================
-- Dive 1: Year-over-Year Player Trends
-- MotherDuck Dive: https://app.motherduck.com/dives/18cf253d-6489-4756-9781-9857eeca55a3
-- =============================================================
-- Shows PPG, eFG%, and assists for players who appeared in all
-- 3 seasons (2022-23, 2023-24, 2024-25) side by side, with a
-- 3-year PPG change column to surface risers and fallers.
--
-- Filters:
--   - Minimum 20 games played per season
--   - Players must appear in all 3 seasons
--
-- Deduplication:
--   Traded players appear multiple times per season in Basketball
--   Reference data (one row per team). We keep the row with the
--   most games played using ROW_NUMBER() OVER (PARTITION BY Player, season).
-- =============================================================

CREATE OR REPLACE VIEW my_db.main.dive_1_yoy_trends AS

WITH deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY Player, season ORDER BY G DESC) AS rn
    FROM my_db.main.nba_player_stats
    WHERE G >= 20
),
clean AS (
    SELECT * FROM deduped WHERE rn = 1
)
SELECT
    s1.Player,
    s1.Pos,
    ROUND(s1.PTS, 1)   AS PTS_23,  ROUND(s1."eFG%", 3) AS eFG_23,  ROUND(s1.AST, 1) AS AST_23,
    ROUND(s2.PTS, 1)   AS PTS_24,  ROUND(s2."eFG%", 3) AS eFG_24,  ROUND(s2.AST, 1) AS AST_24,
    ROUND(s3.PTS, 1)   AS PTS_25,  ROUND(s3."eFG%", 3) AS eFG_25,  ROUND(s3.AST, 1) AS AST_25,
    ROUND(s3.PTS - s1.PTS, 1) AS PPG_3yr_change
FROM clean AS s1
INNER JOIN clean AS s2 ON s1.Player = s2.Player
INNER JOIN clean AS s3 ON s1.Player = s3.Player
WHERE s1.season = '2022-23'
  AND s2.season = '2023-24'
  AND s3.season = '2024-25'
ORDER BY PTS_25 DESC;
