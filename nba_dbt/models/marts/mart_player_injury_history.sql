{{ config(materialized='table') }}

with injuries as (
    select * from {{ ref('stg_nba_injuries') }}
),

team_map as (
    select * from {{ ref('team_name_map') }}
),

game_logs as (
    select distinct
        team,
        game_date,
        season
    from {{ ref('fct_player_game_logs') }}
),

-- map full team names to abbreviations
injuries_with_abbrev as (
    select
        i.player_name,
        tm.team_abbreviation as team,
        i.season,
        i.game_date,
        i.status,
        i.injury_reason
    from injuries i
    left join team_map tm
        on i.team = tm.team_name
),

-- join against actual game dates so we only count games that were played
injuries_on_game_days as (
    select
        i.player_name,
        i.team,
        i.season,
        i.game_date,
        i.status,
        i.injury_reason
    from injuries_with_abbrev i
    inner join game_logs gl
        on i.game_date = gl.game_date
        and i.team = gl.team
        and i.season = gl.season
),

games_missed as (
    select
        player_name,
        team,
        season,
        count(*) filter (where status = 'Out')          as games_missed,
        count(*) filter (where status = 'Questionable') as games_questionable,
        count(*) filter (where status = 'Probable')     as games_probable,
        min(game_date) filter (where status = 'Out')    as first_injury_date,
        max(game_date) filter (where status = 'Out')    as last_injury_date
    from injuries_on_game_days
    group by player_name, team, season
),

injury_types as (
    select
        player_name,
        season,
        string_agg(distinct
            case
                when injury_reason like 'Injury/Illness%'
                    then upper(trim(split_part(split_part(injury_reason, '; ', 2), ';', 1)))
                when injury_reason is not null
                    then upper(trim(injury_reason))
            end,
        ', ') filter (where
            injury_reason is not null
            and injury_reason not in ('', 'Not With Team', 'Trade Pending')
            and injury_reason not like '%Coach%'
            and injury_reason not like '%G League%'
            and injury_reason not like '%Two-Way%'
        ) as injury_types
    from injuries_on_game_days
    where status = 'Out'
    group by player_name, season
)

select
    gm.player_name,
    gm.team,
    gm.season,
    gm.games_missed,
    gm.games_questionable,
    gm.games_probable,
    gm.first_injury_date,
    gm.last_injury_date,
    it.injury_types
from games_missed gm
left join injury_types it
    on gm.player_name = it.player_name
    and gm.season = it.season
where gm.games_missed > 0
order by gm.games_missed desc