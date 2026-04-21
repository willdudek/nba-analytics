with base as (
    select * from {{ ref('fct_player_game_logs') }}
),

monthly as (
    select
        player_name,
        team,
        season,
        strftime(date_trunc('month', game_date), '%b %Y') as month,
        date_trunc('month', game_date)                    as month_date,
        count(*)                        as games,
        round(avg(minutes), 1)          as avg_minutes,
        round(avg(points), 1)           as avg_points,
        round(avg(assists), 1)          as avg_assists,
        round(avg(rebounds), 1)         as avg_rebounds,
        round(avg(dawg_index), 2)       as avg_dawg_index,
        round(avg(fg_pct), 3)           as avg_fg_pct,
        round(avg(three_pct), 3)        as avg_three_pct,
        round(avg(plus_minus), 1)       as avg_plus_minus
    from base
    group by player_name, team, season, date_trunc('month', game_date)
    having count(*) >= 3
)

select * from monthly
order by player_name, season, month_date
