-- =============================================================
-- Dive 3: Shooting Profile by Position
-- MotherDuck Dive: https://app.motherduck.com/dives/a842b4b2-2433-42c3-8f43-121b8cbf3611
-- =============================================================
-- Maps 3-point attempt rate (how often a player shoots threes)
-- vs 3P% (how efficiently) broken down by position and season.
-- Good for spotting high-volume/low-efficiency volume shooters,
-- catch-and-shoot specialists, and positional trends in the
-- modern NBA.
--
-- Filters:
--   - Minimum 20 games played per season
--   - Minimum 15 MPG per season
--   - Minimum 1 three-point attempt per game
--   - Standard 5 positions only (PG, SG, SF, PF, C)
--
-- Key columns:
--   avg_3pa    — average 3-point attempts per game
--   three_pct  — 3P% expressed as a percentage (e.g. 37.5)
--   three_rate — 3PA as % of total FGA (volume indicator)
--
-- Deduplication:
--   Traded players appear multiple times per season in Basketball
--   Reference data. We keep the row with the most games played
--   using ROW_NUMBER() OVER (PARTITION BY Player, season).
-- =============================================================

CREATE OR REPLACE VIEW my_db.main.dive_3_shooting_profile AS

WITH deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY Player, season ORDER BY G DESC) AS rn
    FROM my_db.main.nba_player_stats
    WHERE G >= 20
      AND MP >= 15
),
clean AS (
    SELECT * FROM deduped WHERE rn = 1
)
SELECT
    Player,
    Pos,
    season,
    ROUND(AVG("3PA"), 1)                                    AS avg_3pa,
    ROUND(AVG("3P%") * 100, 1)                             AS three_pct,
    ROUND(AVG(FGA), 1)                                      AS avg_fga,
    ROUND(AVG("3PA") / NULLIF(AVG(FGA), 0) * 100, 1)      AS three_rate
FROM clean
WHERE "3PA" >= 1
  AND Pos IN ('PG', 'SG', 'SF', 'PF', 'C')
GROUP BY Player, Pos, season;
