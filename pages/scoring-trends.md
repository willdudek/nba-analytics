---
title: Year-over-Year Scoring Trends
---

# Year-over-Year Scoring Trends

Player performance across three seasons (2022-23 through 2024-25), tracking points, shooting efficiency, and assists for players who appeared in all three seasons.

```sql trends
select
  Player,
  Pos,
  PTS_23 as "PPG 22-23",
  PTS_24 as "PPG 23-24",
  PTS_25 as "PPG 24-25",
  eFG_23 as "eFG% 22-23",
  eFG_24 as "eFG% 23-24",
  eFG_25 as "eFG% 24-25",
  PPG_3yr_change as "3yr PPG Change"
from motherduck.dive_1_yoy_trends
order by "PPG 24-25" desc
```

<DataTable data={trends} search=true rows=20>
  <Column id="Player" />
  <Column id="Pos" />
  <Column id="PPG 22-23" fmt="num1"/>
  <Column id="PPG 23-24" fmt="num1"/>
  <Column id="PPG 24-25" fmt="num1"/>
  <Column id="eFG% 22-23" fmt="pct1"/>
  <Column id="eFG% 23-24" fmt="pct1"/>
  <Column id="eFG% 24-25" fmt="pct1"/>
  <Column id="3yr PPG Change" fmt="num1" contentType=delta/>
</DataTable>
