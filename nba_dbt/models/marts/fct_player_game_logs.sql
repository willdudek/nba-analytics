with source as (
    select * from {{ ref('stg_nba_game_logs') }}
    where minutes > 0
)

select
    player_id,
    player_name,
    team,
    team_name,
    game_id,
    game_date,
    season,
    home_away,
    opponent,
    win_loss,
    minutes,
    points,
    assists,
    rebounds,
    off_rebounds,
    steals,
    blocks,
    turnovers,
    fg_makes,
    fg_attempts,
    fg_pct,
    three_makes,
    three_attempts,
    three_pct,
    ft_makes,
    ft_attempts,
    ft_pct,
    plus_minus,
    double_double,
    triple_double,
    -- dawg energy per game
    round(off_rebounds + steals + blocks, 2) as dawg_index
from source
