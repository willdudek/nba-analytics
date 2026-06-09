{{ config(materialized='view') }}

with source as (
    select * from {{ source('nba', 'nba_injuries') }}
),

cleaned as (
    select
        strptime(game_date, '%m/%d/%Y')::date           as game_date,
        game_time                                        as game_time,
        matchup                                          as matchup,
        team                                             as team,
        case
            when player_name like '%,%'
                then trim(split_part(player_name, ',', 2)) || ' ' || trim(split_part(player_name, ',', 1))
            else trim(player_name)
        end                                              as player_name,
        current_status                                   as status,
        reason                                           as injury_reason,
        season                                           as season
    from source
),

deduped as (
    select
        game_date,
        team,
        player_name,
        season,
        case
            when max(case status when 'Out' then 4 when 'Doubtful' then 3 when 'Questionable' then 2 when 'Probable' then 1 else 0 end) = 4 then 'Out'
            when max(case status when 'Out' then 4 when 'Doubtful' then 3 when 'Questionable' then 2 when 'Probable' then 1 else 0 end) = 3 then 'Doubtful'
            when max(case status when 'Out' then 4 when 'Doubtful' then 3 when 'Questionable' then 2 when 'Probable' then 1 else 0 end) = 2 then 'Questionable'
            when max(case status when 'Out' then 4 when 'Doubtful' then 3 when 'Questionable' then 2 when 'Probable' then 1 else 0 end) = 1 then 'Probable'
            else 'Available'
        end                                              as status,
        max(injury_reason)                               as injury_reason
    from cleaned
    group by game_date, team, player_name, season
)

select * from deduped