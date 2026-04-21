with base as (
    select * from {{ ref('fct_player_game_logs') }}
),

monthly as (
    select
        player_name,
        team,
        strftime(date_trunc('month', game_date), '%b') as month_name,
        date_part('month', game_date)                  as calendar_month_num,
        -- Remap to NBA season order: Oct=1, Nov=2, Dec=3, Jan=4, Feb=5, Mar=6, Apr=7
        -- Regular season runs October through April
        CASE date_part('month', game_date)
            WHEN 10 THEN 1
            WHEN 11 THEN 2
            WHEN 12 THEN 3
            WHEN 1  THEN 4
            WHEN 2  THEN 5
            WHEN 3  THEN 6
            WHEN 4  THEN 7
        END                                            as season_month_order,
        -- Prefixed label forces alphabetical = season order in Evidence charts
        -- Workaround for Evidence categorical x-axis sorting limitation
        CASE date_part('month', game_date)
            WHEN 10 THEN '1-Oct'
            WHEN 11 THEN '2-Nov'
            WHEN 12 THEN '3-Dec'
            WHEN 1  THEN '4-Jan'
            WHEN 2  THEN '5-Feb'
            WHEN 3  THEN '6-Mar'
            WHEN 4  THEN '7-Apr'
        END                                            as season_month_label,
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
order by player_name, season_month_order
