with base as (
    select * from {{ ref('fct_player_game_logs') }}
)

select
    player_name,
    team,
    opponent,
    season,
    count(*)                        as games,
    round(avg(minutes), 1)          as avg_minutes,
    round(avg(points), 1)           as avg_points,
    round(avg(assists), 1)          as avg_assists,
    round(avg(rebounds), 1)         as avg_rebounds,
    round(avg(steals), 1)           as avg_steals,
    round(avg(blocks), 1)           as avg_blocks,
    round(avg(three_pct), 3)        as avg_three_pct,
    round(avg(plus_minus), 1)       as avg_plus_minus,
    round(avg(dawg_index), 2)       as avg_dawg_index,
    sum(case when win_loss = 'W' then 1 else 0 end) as wins,
    sum(case when win_loss = 'L' then 1 else 0 end) as losses
from base
group by player_name, team, opponent, season
having count(*) >= 2
order by player_name, season, avg_points desc
