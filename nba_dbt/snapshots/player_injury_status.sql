{% snapshot player_injury_status %}

{{
    config(
        target_schema='main',
        unique_key='snapshot_id',
        strategy='check',
        check_cols=['status', 'injury_reason'],
    )
}}

select
    {{ dbt_utils.generate_surrogate_key(['game_date', 'player_name', 'team', 'season']) }} as snapshot_id,
    game_date,
    season,
    team,
    player_name,
    status,
    injury_reason
from {{ ref('stg_nba_injuries') }}

{% endsnapshot %}