with guards as (
    select
        player_name,
        season,
        team,
        games_played,
        off_rebounds_per_game,
        steals_per_game,
        blocks_per_game,
        round(off_rebounds_per_game + steals_per_game + blocks_per_game, 2) as dawg_index
    from {{ ref('stg_nba_player_stats') }}
    where position in ('PG', 'SG')
      and games_played >= 20
)

select
    player_name,
    season,
    team,
    games_played,
    dawg_index,
    off_rebounds_per_game   as orb,
    steals_per_game         as stl,
    blocks_per_game         as blk,
    round(dawg_index - lag(dawg_index)
        over (partition by player_name order by season), 2) as dawg_delta
from guards
order by season, dawg_index desc
