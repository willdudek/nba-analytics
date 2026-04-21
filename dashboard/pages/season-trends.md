---
title: In-Season Trends
---

# In-Season Trends

Monthly performance averages by player, aggregated across all seasons. Search for any player in the table below to explore their monthly splits.

```sql celtics
select
  player_name,
  month_name,
  month_num,
  avg_points,
  avg_assists,
  avg_rebounds,
  avg_three_pct
from motherduck.mart_monthly_player_averages
where player_name in ('Jayson Tatum', 'Jaylen Brown', 'Derrick White', 'Payton Pritchard', 'Sam Hauser')
order by month_num
```

```sql monthly
select
  player_name,
  month_name,
  month_num,
  games,
  avg_points,
  avg_assists,
  avg_rebounds,
  avg_steals,
  avg_blocks,
  avg_dawg_index,
  avg_three_pct,
  avg_minutes,
  avg_plus_minus
from motherduck.mart_monthly_player_averages
order by player_name, month_num
```

<LineChart
  data={celtics}
  x=month_name
  y=avg_points
  series=player_name
  title="Points Per Game by Month (Celtics Big Ballers Only)"
/>

<LineChart
  data={celtics}
  x=month_name
  y=avg_assists
  series=player_name
  title="Assists Per Game by Month (Celtics Big Ballers Only)"
/>

<LineChart
  data={celtics}
  x=month_name
  y=avg_rebounds
  series=player_name
  title="Rebounds Per Game by Month (Celtics Big Ballers Only)"
/>

<LineChart
  data={celtics}
  x=month_name
  y=avg_three_pct
  series=player_name
  title="3-Point % by Month (Celtics Big Ballers Only)"
  yFmt=pct1
/>

<DataTable data={monthly} search=true rows=15>
  <Column id="player_name" title="Player"/>
  <Column id="month_name" title="Month"/>
  <Column id="games" title="G"/>
  <Column id="avg_minutes" fmt="num1" title="MPG"/>
  <Column id="avg_points" fmt="num1" title="PPG"/>
  <Column id="avg_assists" fmt="num1" title="APG"/>
  <Column id="avg_rebounds" fmt="num1" title="RPG"/>
  <Column id="avg_steals" fmt="num1" title="SPG"/>
  <Column id="avg_blocks" fmt="num1" title="BPG"/>
  <Column id="avg_dawg_index" fmt="num2" title="Dawg"/>
  <Column id="avg_three_pct" fmt="pct1" title="3P%"/>
  <Column id="avg_plus_minus" fmt="num1" title="+/-"/>
</DataTable>
