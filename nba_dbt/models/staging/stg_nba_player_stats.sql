{{ config(materialized='view') }}

with source as (
    select * from my_db.main.nba_player_stats
    where Player != 'League Average'
),

deduplicated as (
    select
        Player                          as player_name,
        season,
        Team                            as team,
        Pos                             as position,
        G                               as games_played,
        GS                              as games_started,
        MP                              as minutes_per_game,
        PTS                             as points_per_game,
        AST                             as assists_per_game,
        TRB                             as rebounds_per_game,
        ORB                             as off_rebounds_per_game,
        STL                             as steals_per_game,
        BLK                             as blocks_per_game,
        TOV                             as turnovers_per_game,
        "FG%"                           as fg_pct,
        "eFG%"                          as efg_pct,
        "3P"                            as three_point_makes,
        "3PA"                           as three_point_attempts,
        "3P%"                           as three_point_pct,
        "FT%"                           as ft_pct,
        ROW_NUMBER() OVER (
            PARTITION BY Player, season
            ORDER BY G DESC
        )                               as row_num
    from source
)

select * from deduplicated
where row_num = 1
