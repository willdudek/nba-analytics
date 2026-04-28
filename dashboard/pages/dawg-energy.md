---
title: Dawg Energy Index
---

# Dawg Energy Index

Hustle metric for guards combining offensive rebounds, steals, and blocks into a single index. High dawg energy = doing the dirty work.

**How guards are defined:** Any player listed as a PG or SG in at least one season. All available seasons for those players are included — even seasons where they were listed at another position. This ensures players like Scottie Barnes and Josh Hart appear across their full career arc.

**Dawg Index formula:** Offensive rebounds + steals + blocks per game.

```sql dawg
select
  player_name,
  season,
  dawg_index,
  orb,
  stl,
  blk
from motherduck.mart_dawg_energy
order by dawg_index desc
```

```sql dawg_top10
select
  player_name,
  season,
  dawg_index
from motherduck.mart_dawg_energy
where player_name in (
  select player_name
  from motherduck.mart_dawg_energy
  group by player_name
  order by max(dawg_index) desc
  limit 10
)
order by player_name, season
```

<BarChart
  data={dawg_top10}
  x=player_name
  y=dawg_index
  series=season
  title="Top 10 Dawg Energy — Guards by Season"
  swapXY=true
/>

<DataTable data={dawg} search=true rows=20>
  <Column id="player_name" title="Player"/>
  <Column id="season" />
  <Column id="dawg_index" fmt="num2" title="Dawg Index"/>
  <Column id="orb" fmt="num2" title="ORB"/>
  <Column id="stl" fmt="num2" title="STL"/>
  <Column id="blk" fmt="num2" title="BLK"/>
</DataTable>