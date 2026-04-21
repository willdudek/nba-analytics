---
title: Player vs Opponent
---

# Player vs Opponent

Search a player to see their performance against every opponent across all four seasons. Search by opponent to narrow further.

```sql overall
select
  player_name,
  season,
  count(*)                        as games,
  round(avg(avg_points), 1)       as ppg,
  round(avg(avg_assists), 1)      as apg,
  round(avg(avg_rebounds), 1)     as rpg,
  round(avg(avg_steals), 1)       as spg,
  round(avg(avg_dawg_index), 2)   as dawg,
  round(avg(avg_plus_minus), 1)   as plus_minus,
  round(avg(avg_three_pct), 3)    as three_pct,
  round(avg(avg_minutes), 1) as avg_minutes
from motherduck.mart_player_vs_opponent
group by player_name, season
order by season desc, ppg desc
```

```sql matchups
select
  player_name,
  season,
  opponent,
  games,
  avg_points       as ppg,
  avg_assists      as apg,
  avg_rebounds     as rpg,
  avg_steals       as spg,
  avg_blocks       as bpg,
  avg_dawg_index   as dawg,
  avg_plus_minus   as plus_minus,
  avg_three_pct    as three_pct,
  avg_minutes      as avg_minutes
from motherduck.mart_player_vs_opponent
order by season desc, avg_points desc
```

<DataTable data={overall} search=true rows=10 title="Season Averages (All Opponents)">
  <Column id="player_name" title="Player"/>
  <Column id="season" />
  <Column id="games" title="G"/>
  <Column id="avg_minutes" fmt="num1" title="MPG"/>
  <Column id="ppg" fmt="num1" title="PPG"/>
  <Column id="apg" fmt="num1" title="APG"/>
  <Column id="rpg" fmt="num1" title="RPG"/>
  <Column id="spg" fmt="num1" title="SPG"/>
  <Column id="dawg" fmt="num2" title="Dawg"/>
  <Column id="plus_minus" fmt="num1" title="+/-"/>
  <Column id="three_pct" fmt="pct1" title="3P%"/>
</DataTable>

<DataTable data={matchups} search=true rows=15 title="By Opponent">
  <Column id="player_name" title="Player"/>
  <Column id="season" />
  <Column id="opponent" title="Opponent"/>
  <Column id="games" title="G"/>
  <Column id="avg_minutes" fmt="num1" title="MPG"/>
  <Column id="ppg" fmt="num1" title="PPG"/>
  <Column id="apg" fmt="num1" title="APG"/>
  <Column id="rpg" fmt="num1" title="RPG"/>
  <Column id="spg" fmt="num1" title="SPG"/>
  <Column id="bpg" fmt="num1" title="BPG"/>
  <Column id="dawg" fmt="num2" title="Dawg"/>
  <Column id="plus_minus" fmt="num1" title="+/-"/>
  <Column id="three_pct" fmt="pct1" title="3P%"/>
</DataTable>
