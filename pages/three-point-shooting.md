---
title: 3-Point Shooting Trends
---

# 3-Point Shooting Trends

Top 10 shooters from 2024-25 (min. 20 games, 15 MPG, 3 attempts/game) tracked across all three seasons.

```sql three_pt
select
  Player,
  season,
  three_pt_pct as "3P%",
  total_attempts as "Total Attempts"
from motherduck.dive_2_3pt_yoy
order by Player, season
```

<LineChart
  data={three_pt}
  x=season
  y="3P%"
  series=Player
  title="3-Point % by Season — Top 10 Shooters (2024-25)"
  yFmt=pct1
/>

<DataTable data={three_pt} rows=15>
  <Column id="Player" />
  <Column id="season" />
  <Column id="3P%" fmt="pct1"/>
  <Column id="Total Attempts" fmt="num0"/>
</DataTable>
