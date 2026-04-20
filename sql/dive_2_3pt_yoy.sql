-- =============================================================
-- Dive 2: 3-Point % Year Over Year — Top 10 Shooters
-- MotherDuck Dive: https://app.motherduck.com/dives/5cae9f62-9e9e-4758-be55-58e9743b143a
-- =============================================================
-- Tracks 3-point shooting percentage across all 3 seasons for
-- the top 10 shooters in 2024-25. Useful for spotting improving
-- and declining shooters, and separating real improvement from
-- sample noise.
--
-- Filters:
--   - Minimum 20 games played per season
--   - Minimum 15 MPG per season
--   - Minimum 3 three-point attempts per game per season
--   - Ranked by 3P% in 2024-25, top 10 only
--
-- Deduplication:
--   Traded players appear multiple times per season in Basketball
--   Reference data. We keep the row with the most games played
--   using ROW_NUMBER() OVER (PARTITION BY Player, season).
-- =============================================================

WITH deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY Player, season ORDER BY G DESC) AS rn
    FROM my_db.main.nba_player_stats
    WHERE G >= 20
      AND MP >= 15
),
clean AS (
    SELECT * FROM deduped WHERE rn = 1
),
qualified AS (
    -- Players must appear in all 3 seasons with enough attempts
    SELECT Player
    FROM clean
    WHERE "3PA" >= 3
    GROUP BY Player
    HAVING COUNT(DISTINCT season) = 3
),
top10 AS (
    -- Rank by 2024-25 3P% and take top 10
    SELECT c.Player
    FROM clean c
    INNER JOIN qualified q ON c.Player = q.Player
    WHERE c.season = '2024-25'
    ORDER BY c."3P%" DESC
    LIMIT 10
)
SELECT
    c.Player,
    c.season,
    ROUND(c."3P%" * 100, 1) AS three_pct,
    ROUND(c."3PA", 1)       AS three_pa
FROM clean c
INNER JOIN top10 t ON c.Player = t.Player
WHERE c."3PA" >= 3
ORDER BY c.Player, c.season;
