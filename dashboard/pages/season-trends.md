---
title: In-Season Trends
---

# In-Season Trends

Monthly performance averages by player, aggregated across all seasons. Charts show months 1–7 following the NBA regular season calendar (1=Oct, 2=Nov, 3=Dec, 4=Jan, 5=Feb, 6=Mar, 7=Apr). Search for any player in the table below to explore their monthly splits.

```sql celtics_pts
select
  player_name,
  season_month_order,
  avg_points
from motherduck.mart_monthly_player_averages
where player_name in ('Jayson Tatum', 'Jaylen Brown', 'Derrick White', 'Payton Pritchard', 'Sam Hauser')
  and season_month_order is not null
order by player_name, season_month_order
```

```sql celtics_ast
select
  player_name,
  season_month_order,
  avg_assists
from motherduck.mart_monthly_player_averages
where player_name in ('Jayson Tatum', 'Jaylen Brown', 'Derrick White', 'Payton Pritchard', 'Sam Hauser')
  and season_month_order is not null
order by player_name, season_month_order
```

```sql celtics_reb
select
  player_name,
  season_month_order,
  avg_rebounds
from motherduck.mart_monthly_player_averages
where player_name in ('Jayson Tatum', 'Jaylen Brown', 'Derrick White', 'Payton Pritchard', 'Sam Hauser')
  and season_month_order is not null
order by player_name, season_month_order
```

```sql celtics_3pt
select
  player_name,
  season_month_order,
  avg_three_pct
from motherduck.mart_monthly_player_averages
where player_name in ('Jayson Tatum', 'Jaylen Brown', 'Derrick White', 'Payton Pritchard', 'Sam Hauser')
  and season_month_order is not null
order by player_name, season_month_order
```

```sql monthly
select
  player_name,
  month_name,
  season_month_order,
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
where season_month_order is not null
order by player_name, season_month_order
```

<LineChart
  data={celtics_pts}
  x=season_month_order
  y=avg_points
  series=player_name
  title="Points Per Game by Month (Celtics Big Ballers Only)"
  xMin=1
  xMax=7
/>

<LineChart
  data={celtics_ast}
  x=season_month_order
  y=avg_assists
  series=player_name
  title="Assists Per Game by Month (Celtics Big Ballers Only)"
  xMin=1
  xMax=7
/>

<LineChart
  data={celtics_reb}
  x=season_month_order
  y=avg_rebounds
  series=player_name
  title="Rebounds Per Game by Month (Celtics Big Ballers Only)"
  xMin=1
  xMax=7
/>

<LineChart
  data={celtics_3pt}
  x=season_month_order
  y=avg_three_pct
  series=player_name
  title="3-Point % by Month (Celtics Big Ballers Only)"
  xMin=1
  xMax=7
  yFmt=pct1
/>

<DataTable data={monthly} search=true rows=15>
  <Column id="player_name" title="Player"/>
  <Column id="month_name" title="Month"/>
  <Column id="season_month_order" title="Month #"/>
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