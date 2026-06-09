{{ config(materialized='table') }}

with injuries as (
    select * from {{ ref('stg_nba_injuries') }}
),

team_map as (
    select * from {{ ref('team_name_map') }}
),

injuries_with_abbrev as (
    select
        i.game_date,
        i.season,
        tm.team_abbreviation                            as team,
        i.player_name,
        i.status,
        i.injury_reason
    from injuries i
    left join team_map tm
        on i.team = tm.team_name
),

-- aggregate to team level per game date
team_profile as (
    select
        game_date,
        season,
        team,
        count(*) filter (where status = 'Out')          as players_out,
        count(*) filter (where status = 'Doubtful')     as players_doubtful,
        count(*) filter (where status = 'Questionable') as players_questionable,
        count(*) filter (where status = 'Probable')     as players_probable,
        -- list of out players for context
        string_agg(player_name, ', ')
            filter (where status = 'Out')               as players_out_names,
        -- list of questionable players
        string_agg(player_name, ', ')
            filter (where status = 'Questionable')      as players_questionable_names,
        -- total unavailable (Out + Doubtful)
        count(*) filter (where status in ('Out', 'Doubtful')) as players_unavailable
    from injuries_with_abbrev
    where team is not null
    group by game_date, season, team
)

select * from team_profile
order by game_date desc, players_unavailable desc