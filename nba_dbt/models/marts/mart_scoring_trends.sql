with players as (
    select
        player_name,
        season,
        team,
        position,
        games_played,
        points_per_game,
        efg_pct,
        assists_per_game,
        rebounds_per_game
    from {{ ref('stg_nba_player_stats') }}
    where games_played >= 20
),

with_deltas as (
    select
        player_name,
        season,
        team,
        position,
        games_played,
        round(points_per_game, 1)               as ppg,
        round(efg_pct, 3)                       as efg_pct,
        round(assists_per_game, 1)              as apg,
        round(rebounds_per_game, 1)             as rpg,
        round(points_per_game - lag(points_per_game)
            over (partition by player_name order by season), 1)
                                                as ppg_delta,
        round(efg_pct - lag(efg_pct)
            over (partition by player_name order by season), 3)
                                                as efg_delta
    from players
)

select * from with_deltas
order by season, ppg desc
