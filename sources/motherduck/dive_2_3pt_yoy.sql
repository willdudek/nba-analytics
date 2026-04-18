WITH deduped AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY Player, season ORDER BY G DESC) AS rn
  FROM nba_player_stats
),
filtered AS (
  SELECT Player, season, "3P%", "3PA", G
  FROM deduped
  WHERE rn = 1
    AND G >= 20
    AND MP >= 15
    AND "3PA" >= 3
),
top_shooters AS (
  SELECT Player
  FROM filtered
  WHERE season = '2024-25'
  ORDER BY "3P%" DESC
  LIMIT 10
)
SELECT f.Player, f.season, ROUND(f."3P%", 3) AS three_pt_pct, ROUND(f.G * f."3PA", 1) AS total_attempts
FROM filtered f
JOIN top_shooters t ON f.Player = t.Player
ORDER BY f.Player, f.season
