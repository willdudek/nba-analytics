with ever_a_guard as (
    select distinct player_name
    from {{ ref('stg_nba_player_stats') }}
    where position in ('PG', 'SG')
),

all_seasons as (
    select
        s.player_name,
        s.season,
        s.team,
        s.games_played,
        s.off_rebounds_per_game,
        s.steals_per_game,
        s.blocks_per_game,
        round(s.off_rebounds_per_game + s.steals_per_game + s.blocks_per_game, 2) as dawg_index
    from {{ ref('stg_nba_player_stats') }} s
    inner join ever_a_guard g on s.player_name = g.player_name
    where s.games_played >= 20
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
from all_seasons
order by season, dawg_index desc