{{ config(materialized='table') }}

with player_stats as (
    select * from {{ source('nba', 'nba_player_stats') }}
    where Player != 'League Average'
),

all_stints as (
    select
        Player                          as player_name,
        season,
        Team                            as team,
        G                               as games_played,
        PTS                             as points_per_game,
        AST                             as assists_per_game,
        TRB                             as rebounds_per_game,
        "FG%"                           as fg_pct,
        case
            when Team in ('TOT', '2TM', '3TM', '4TM') then 1 else 0
        end                             as is_total_row,
        ROW_NUMBER() OVER (
            PARTITION BY Player, season
            ORDER BY G DESC
        )                               as stint_rank
    from player_stats
),

traded_players as (
    select distinct player_name, season
    from all_stints
    where is_total_row = 1
),

trade_stints as (
    select
        a.player_name,
        a.season,
        a.team,
        a.games_played,
        a.points_per_game,
        a.assists_per_game,
        a.rebounds_per_game,
        a.fg_pct,
        false                           as is_primary_team,
        true                            as was_traded
    from all_stints a
    inner join traded_players t
        on a.player_name = t.player_name
        and a.season = t.season
    where a.is_total_row = 0
),

single_team as (
    select
        a.player_name,
        a.season,
        a.team,
        a.games_played,
        a.points_per_game,
        a.assists_per_game,
        a.rebounds_per_game,
        a.fg_pct,
        true                            as is_primary_team,
        false                           as was_traded
    from all_stints a
    left join traded_players t
        on a.player_name = t.player_name
        and a.season = t.season
    where t.player_name is null
    and a.is_total_row = 0
),

combined as (
    select * from trade_stints
    union all
    select * from single_team
)

select
    player_name,
    season,
    team,
    games_played,
    round(points_per_game, 1)           as points_per_game,
    round(assists_per_game, 1)          as assists_per_game,
    round(rebounds_per_game, 1)         as rebounds_per_game,
    round(fg_pct, 3)                    as fg_pct,
    is_primary_team,
    was_traded,
    ROW_NUMBER() OVER (
        PARTITION BY player_name, season
        ORDER BY games_played DESC
    )                                   as stint_rank
from combined
order by player_name, season, games_played desc
