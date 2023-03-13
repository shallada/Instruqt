---
slug: timeseries
id: o3etdx3xis7c
type: challenge
title: Druid SQL Explain Plan Timeseries
teaser: Let's see SQL queries that Druid translates into timeseries queries
notes:
- type: text
  contents: Please be patient while we prepare the lab
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
- title: Druid Console
  type: website
  url: https://container-8443-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
difficulty: basic
timelimit: 600
---

In this exercise, let's investigate SQL queries that map to Native Timeseries queries.
These queries perform only time-based aggregation.
Read more about Timeseries queries <a href="https://druid.apache.org/docs/latest/querying/timeseriesquery.html" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

To create a Timeseries native query, we need to aggregate rows based on the <i>__time</i> column.
Here's an example of using a _GROUP BY_ clause to perform this kind of aggregation.

```
SELECT TIME_FLOOR(__time,'PT1m'), COUNT(*)
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2016-06-27 00:00:00'
  AND TIMESTAMP '2016-06-28 00:00:00'
GROUP BY 1
```

<details>
  <summary style="color:cyan"><b>What does this query do?</b></summary>
<hr style="background-color:cyan">
This query aggregates records within the same minute using <i>TIME_FLOOR(__time,'PT1m')</i> as described in the <i>SELECT</i> clause.
This expression truncates the timestamp in the <i>__time</i> column to minutes so that the <i>GROUP BY</i> clause can combine the records into groups.
Notice also that the <i>SELECT</i> clause counts the number of records within each group.
Read more about <i>TIME_FLOOR(__time,'PT1m')</i>  <a href="https://druid.apache.org/docs/latest/querying/sql-scalar.html#date-and-time-functions" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


The following is a command that creates a plan for the above query using Druid's API.
Copy the command, and paste and execute it in the Shell.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT TIME_FLOOR(__time,'"'"'PT1m'"'"'), COUNT(*) FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"' GROUP BY 1"}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > timeseries_plan.json
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, let's open the resulting plan file (named <i>timeseries_plan.json</i>) in the editor.

<a href="#img-2">
  <img alt="Open Timeseries" src="../assets/OpenTimeseries.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Open Timeseries" src="../assets/OpenTimeseries.png" />
</a>


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Notice the following about the plan:
- The value of the _queryType_ field is _timeseries_
- _granularity_ has the value of _MINUTE_
- There is an _aggregation_ object that handles the _COUNT(*)_ operator
- The native query refers to the returned columns as _d0_ for the <i>__time</i> column and _a0_ for the _COUNT(*)_ column

Other than these notable differences, we see that the native query looks a lot like the Scan queries.


<h2 style="color:cyan">Outstanding! We see how to create native timeseries queries!</h2>


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
