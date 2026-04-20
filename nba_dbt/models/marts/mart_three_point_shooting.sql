with players as (
    select
        player_name,
        season,
        team,
        games_played,
        three_point_pct,
        three_point_attempts,
        three_point_makes,
        round(games_played * three_point_attempts, 1) as total_attempts
    from {{ ref('stg_nba_player_stats') }}
    where games_played >= 20
      and three_point_attempts >= 3
),

ranked as (
    select
        player_name,
        season,
        team,
        games_played,
        round(three_point_pct, 3)               as three_point_pct,
        round(three_point_attempts, 1)          as three_pa_per_game,
        total_attempts,
        round(three_point_pct - lag(three_point_pct)
            over (partition by player_name order by season), 3)
                                                as three_pct_delta
    from players
)

select * from ranked
order by season, three_point_pct desc
