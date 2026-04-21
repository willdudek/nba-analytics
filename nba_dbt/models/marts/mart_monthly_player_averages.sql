with base as (
    select * from {{ ref('fct_player_game_logs') }}
),

monthly as (
    select
        player_name,
        team,
        strftime(date_trunc('month', game_date), '%b') as month_name,
        date_part('month', game_date)                  as month_num,
        count(*)                                        as games,
        round(avg(minutes), 1)                          as avg_minutes,
        round(avg(points), 1)                           as avg_points,
        round(avg(assists), 1)                          as avg_assists,
        round(avg(rebounds), 1)                         as avg_rebounds,
        round(avg(steals), 1)                           as avg_steals,
        round(avg(blocks), 1)                           as avg_blocks,
        round(avg(dawg_index), 2)                       as avg_dawg_index,
        round(avg(fg_pct), 3)                           as avg_fg_pct,
        round(avg(three_pct), 3)                        as avg_three_pct,
        round(avg(plus_minus), 1)                       as avg_plus_minus,
        round(avg(turnovers), 1)                        as avg_turnovers
    from base
    group by
        player_name,
        team,
        strftime(date_trunc('month', game_date), '%b'),
        date_part('month', game_date)
    having count(*) >= 3
)

select * from monthly
order by player_name, month_num
