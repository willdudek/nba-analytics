---
title: Dawg Energy Index
---

# Dawg Energy Index

Hustle metric for guards (PG/SG) across three seasons — combining offensive rebounds, steals, and blocks into a single index. High dawg energy = doing the dirty work.

```sql dawg
select
  Player,
  season,
  dawg_index,
  orb,
  stl,
  blk
from motherduck.dive_3_dawg_energy
order by dawg_index desc
```

```sql dawg_top10
select
  Player,
  season,
  dawg_index
from motherduck.dive_3_dawg_energy
where Player in (
  select Player from motherduck.dive_3_dawg_energy
  order by dawg_index desc
  limit 10
)
order by Player, season
```

<BarChart
  data={dawg_top10}
  x=Player
  y=dawg_index
  series=season
  title="Top 10 Dawg Energy — Guards by Season"
  swapXY=true
/>

<DataTable data={dawg} search=true rows=20>
  <Column id="Player" />
  <Column id="season" />
  <Column id="dawg_index" fmt="num2" title="Dawg Index"/>
  <Column id="orb" fmt="num2" title="ORB"/>
  <Column id="stl" fmt="num2" title="STL"/>
  <Column id="blk" fmt="num2" title="BLK"/>
</DataTable>
