---
slug: druid-sql
id: tslx8llukhmh
type: challenge
title: Druid Queries Using the Druid SQL Client
teaser: Use the command line tool to query Druid
notes:
- type: video
  url: ../assets/02-splash.mp4
tabs:
- title: Shell
  type: terminal
  hostname: single-server
difficulty: basic
timelimit: 600
---

Sometimes it's helpful to use a command line interface.
Druid provides a command line client.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start the client as follows.

```
/root/imply-2021.09/bin/dsql
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Try submitting the query from the previous step.

```
SELECT __time, "user", page, added, deleted
  FROM wikipedia
  WHERE (TIMESTAMP '2016-06-27' <= __time
    AND
    __time < TIMESTAMP '2016-06-28')
  LIMIT 10;
```

Notice that we modified the query slightly from the previous challenge.
Specifically, we added _LIMIT 10_ so we only get the first 10 rows.
Notice also that we end command line queries with a semicolon.


Here's another intersting query that tells us the wikipedia update activity (number of lines deleted) by hour of the day.


<details>
  <summary style="color:cyan"><b>How does this query work?</b></summary>
<hr style="background-color:cyan">
Let's break down the various pieces of this query.
<ul>
<li><i>FLOOR(__time to HOUR) AS HourTime</i> selects the <i>__time</i> column and rounds it down to the hour, and labels the column <i>HourTime</i> - learn more <a href="https://druid.apache.org/docs/latest/querying/sql.html#time-functions" target="_blank">here</a></li>
<li><i>SUM(deleted) AS LinesDeleted</i> aggregates the <i>deleted</i> column by summing up all rows for that hour, and labels the column <i>LinesDeleted</i> - learn about <a href="https://druid.apache.org/docs/latest/querying/sql.html#aggregation-functions" target="_blank">aggregation functions</a></li>
<li><i>FROM wikipedia WHERE "__time" BETWEEN...</i> behaves like the <i>WHERE</i> clause in the previous query, which filters down to June 27, 2016 - learn more <a href="https://druid.apache.org/docs/latest/querying/sql.html#from" target="_blank">here</a></li>
<li><i>GROUP BY 1</i> tells Druid to group rows by the first selected column (i.e., HourTime) - we could have also used <i>GROUP BY FLOOR(__time to HOUR)</i> - learn more <a href="https://druid.apache.org/docs/latest/querying/sql.html#group-by" target="_blank">here</a></li>
</ul>
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Submit this query.

```
SELECT FLOOR(__time to HOUR) AS HourTime,
  SUM(deleted) AS LinesDeleted
  FROM wikipedia
  WHERE "__time" BETWEEN
    TIMESTAMP '2016-06-27 00:00:00'
    AND
    TIMESTAMP '2016-06-28 00:00:00'
  GROUP BY 1;
```

In the results from the query, you see the aggregation by hour of the day.
If you only ever cared about an hourly granularity across all queries on this table data source, you could have rolled up the timestamps during ingestion to speed up the query.

Let's try one more query.
This query yields the number of lines added to each channel/page pairing.


<details>
  <summary style="color:cyan"><b>How does this query work?</b></summary>
<hr style="background-color:cyan">
Let's break down the various sections of this query.
<ul>
<li><i>SELECT channel, page, SUM(added) as "Sum"</i> selects three columns with the third being an aggregation named <i>Sum</i> - notice that <i>Sum</i> needs quotes because it is a reserved word</li>
<li><i>FROM wikipedia WHERE "__time" BETWEEN...</i> behaves like the <i>WHERE</i> clause in the first query, which filters down to June 27, 2016</li>
<li><i>GROUP BY channel, page</i> tells Druid to aggregate rows that have the same values for <i>channel</i> and <i>page</i></li>
<li><i>ORDER BY SUM(added) DESC</i> causes the output to be sorted with the highest number of added lines at the top - learn more <a href="https://druid.apache.org/docs/latest/querying/sql.html#order-by" target="_blank">here</a></li>
<li><i>LIMIT 10</i> allows only 10 rows in the output - learn more <a href="https://druid.apache.org/docs/latest/querying/sql.html#limit" target="_blank">here</a></li>
</ul>
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Submit this query.

```
SELECT channel, page, SUM(added) as "Sum"
  FROM wikipedia
  WHERE "__time" BETWEEN
    TIMESTAMP '2016-06-27 00:00:00'
    AND
    TIMESTAMP '2016-06-28 00:00:00'
  GROUP BY channel, page
  ORDER BY SUM(added) DESC
  LIMIT 10;
```

Note that this query uses Druid's _TopN_ feature, which may yield approximate results.
Read more about [_TopN_](https://druid.apache.org/docs/latest/querying/topnquery.html).

<h2 style="color:cyan">Hey! The command line tool is cool!</h2>

<style type="text/css" rel="stylesheet">
.lightbox { display: none; position: fixed; justify-content: center; align-items: center; z-index: 999; top: 0; left: 0; right: 0; bottom: 0; padding: 1rem; background: rgba(0, 0, 0, 0.8); }
.lightbox:target { display: flex; }
.lightbox img { max-height: 100% }
.thumbnail:hover {
    position:fixed;
    top:-25px;
    left:-35px;
    width:500px;
    height:auto;
    display:block;
    z-index:999;
}
</style>
