{{ config(materialized='view') }}

with source as (
    select * from my_db.main.nba_game_logs
),

cleaned as (
    select
        PLAYER_ID                   as player_id,
        PLAYER_NAME                 as player_name,
        TEAM_ABBREVIATION           as team,
        TEAM_NAME                   as team_name,
        GAME_ID                     as game_id,
        GAME_DATE::date             as game_date,
        SEASON                      as season,
        MATCHUP                     as matchup,
        -- derive opponent and home/away from matchup string
        CASE 
            WHEN MATCHUP LIKE '%vs.%' THEN 'Home'
            ELSE 'Away'
        END                         as home_away,
        CASE
            WHEN MATCHUP LIKE '%vs.%' 
                THEN TRIM(SPLIT_PART(MATCHUP, 'vs.', 2))
            ELSE TRIM(SPLIT_PART(MATCHUP, '@', 2))
        END                         as opponent,
        WL                          as win_loss,
        MIN                         as minutes,
        PTS                         as points,
        AST                         as assists,
        REB                         as rebounds,
        OREB                        as off_rebounds,
        STL                         as steals,
        BLK                         as blocks,
        TOV                         as turnovers,
        FGM                         as fg_makes,
        FGA                         as fg_attempts,
        FG_PCT                      as fg_pct,
        FG3M                        as three_makes,
        FG3A                        as three_attempts,
        FG3_PCT                     as three_pct,
        FTM                         as ft_makes,
        FTA                         as ft_attempts,
        FT_PCT                      as ft_pct,
        PLUS_MINUS                  as plus_minus,
        DD2                         as double_double,
        TD3                         as triple_double
    from source
)

select * from cleaned
