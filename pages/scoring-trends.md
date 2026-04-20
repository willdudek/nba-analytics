---
title: Year-over-Year Scoring Trends
---

# Year-over-Year Scoring Trends

Player performance across three seasons (2022-23 through 2024-25), tracking points per game, shooting efficiency, and year-over-year deltas.

```sql trends
select
  player_name,
  season,
  ppg,
  efg_pct,
  apg,
  rpg,
  ppg_delta,
  efg_delta
from motherduck.dive_1_yoy_trends
order by season desc, ppg desc
```

<DataTable data={trends} search=true rows=20>
  <Column id="player_name" title="Player"/>
  <Column id="season" />
  <Column id="ppg" fmt="num1" title="PPG"/>
  <Column id="efg_pct" fmt="pct1" title="eFG%"/>
  <Column id="apg" fmt="num1" title="APG"/>
  <Column id="rpg" fmt="num1" title="RPG"/>
  <Column id="ppg_delta" fmt="num1" title="PPG Δ" contentType=delta/>
  <Column id="efg_delta" fmt="pct1" title="eFG% Δ" contentType=delta/>
</DataTable>
