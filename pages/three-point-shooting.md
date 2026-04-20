---
title: 3-Point Shooting Trends
---

# 3-Point Shooting Trends

Top shooters tracked across three seasons (min. 20 games, 3 attempts/game).

```sql three_pt
select
  player_name,
  season,
  three_point_pct,
  three_pa_per_game,
  total_attempts
from motherduck.dive_2_3pt_yoy
order by player_name, season
```

<LineChart
  data={three_pt}
  x=season
  y=three_point_pct
  series=player_name
  title="3-Point % by Season — Top Shooters"
  yFmt=pct1
/>

<DataTable data={three_pt} rows=15>
  <Column id="player_name" title="Player"/>
  <Column id="season" />
  <Column id="three_point_pct" fmt="pct1" title="3P%"/>
  <Column id="three_pa_per_game" fmt="num1" title="3PA/G"/>
  <Column id="total_attempts" fmt="num0" title="Total Attempts"/>
</DataTable>
