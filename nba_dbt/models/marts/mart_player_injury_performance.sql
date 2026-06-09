{{ config(materialized='table') }}

with game_logs as (
    select
        player_name,
        team,
        season,
        game_date,
        points,
        rebounds,
        assists,
        fg_pct,
        minutes
    from {{ ref('fct_player_game_logs') }}
    where minutes > 0
),

injuries as (
    select * from {{ ref('stg_nba_injuries') }}
),

team_map as (
    select * from {{ ref('team_name_map') }}
),

injuries_with_abbrev as (
    select
        i.player_name,
        tm.team_abbreviation    as team,
        i.season,
        i.game_date,
        i.status,
        i.injury_reason
    from injuries i
    left join team_map tm on i.team = tm.team_name
),

-- find the first date of each injury spell (Out status)
injury_spells as (
    select
        player_name,
        team,
        season,
        min(game_date)          as injury_start,
        max(game_date)          as injury_end,
        max(injury_reason)      as injury_reason
    from injuries_with_abbrev
    where status = 'Out'
    and injury_reason like 'Injury/Illness%'
    group by player_name, team, season
),

-- for each injury spell, get the 5 games before
games_before as (
    select
        s.player_name,
        s.team,
        s.season,
        s.injury_start,
        s.injury_reason,
        avg(g.points)           as avg_points_before,
        avg(g.rebounds)         as avg_rebounds_before,
        avg(g.assists)          as avg_assists_before,
        avg(g.fg_pct)           as avg_fg_pct_before,
        avg(g.minutes)          as avg_minutes_before,
        count(*)                as games_before_count
    from injury_spells s
    inner join game_logs g
        on g.player_name = s.player_name
        and g.game_date < s.injury_start
    where g.game_date >= (
        select coalesce(min(g2.game_date), s.injury_start)
        from (
            select game_date
            from game_logs g2
            where g2.player_name = s.player_name
            and g2.game_date < s.injury_start
            order by g2.game_date desc
            limit 5
        ) g2
    )
    group by s.player_name, s.team, s.season, s.injury_start, s.injury_reason
),

-- for each injury spell, get the 5 games after returning
games_after as (
    select
        s.player_name,
        s.team,
        s.season,
        s.injury_start,
        avg(g.points)           as avg_points_after,
        avg(g.rebounds)         as avg_rebounds_after,
        avg(g.assists)          as avg_assists_after,
        avg(g.fg_pct)           as avg_fg_pct_after,
        avg(g.minutes)          as avg_minutes_after,
        count(*)                as games_after_count
    from injury_spells s
    inner join game_logs g
        on g.player_name = s.player_name
        and g.game_date > s.injury_end
    where g.game_date <= (
        select coalesce(max(g2.game_date), s.injury_end)
        from (
            select game_date
            from game_logs g2
            where g2.player_name = s.player_name
            and g2.game_date > s.injury_end
            order by g2.game_date asc
            limit 5
        ) g2
    )
    group by s.player_name, s.team, s.season, s.injury_start
)

select
    b.player_name,
    b.team,
    b.season,
    b.injury_start,
    b.injury_reason,
    -- before stats
    round(b.avg_points_before, 1)       as avg_points_before,
    round(b.avg_rebounds_before, 1)     as avg_rebounds_before,
    round(b.avg_assists_before, 1)      as avg_assists_before,
    round(b.avg_fg_pct_before, 3)       as avg_fg_pct_before,
    round(b.avg_minutes_before, 1)      as avg_minutes_before,
    b.games_before_count,
    -- after stats
    round(a.avg_points_after, 1)        as avg_points_after,
    round(a.avg_rebounds_after, 1)      as avg_rebounds_after,
    round(a.avg_assists_after, 1)       as avg_assists_after,
    round(a.avg_fg_pct_after, 3)        as avg_fg_pct_after,
    round(a.avg_minutes_after, 1)       as avg_minutes_after,
    a.games_after_count,
    -- deltas
    round(a.avg_points_after - b.avg_points_before, 1)     as points_delta,
    round(a.avg_rebounds_after - b.avg_rebounds_before, 1) as rebounds_delta,
    round(a.avg_assists_after - b.avg_assists_before, 1)   as assists_delta
from games_before b
left join games_after a
    on b.player_name = a.player_name
    and b.season = a.season
    and b.injury_start = a.injury_start
where b.games_before_count >= 3
order by abs(coalesce(points_delta, 0)) desc