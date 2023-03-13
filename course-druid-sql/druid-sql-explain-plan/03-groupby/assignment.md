---
slug: groupby
id: vwhfwexkqvme
type: challenge
title: Druid SQL Explain Plan GroupBy
teaser: Let's see SQL queries that Druid translates into native GroupBy queries
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

In the previous exercise, we aggregated rows of data using <i>__time</i> values and we saw that the resulting native query type was Timeseries.
In this exercise we will aggregate on an additional column and see that the resulting native query type is GroupBy.
Read more about GroupBy native queries <a href="https://druid.apache.org/docs/latest/querying/groupbyquery.html" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

To create a GroupBy native query, we need to aggregate rows based on the <i>__time</i> column and some other column.
In this example, we'll add _channel_ to the _GROUP BY_ clause to form the following query.

```
SELECT TIME_FLOOR(__time,'PT1m'), channel, COUNT(*)
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2016-06-27 00:00:00'
  AND TIMESTAMP '2016-06-28 00:00:00'
GROUP BY 1, 2
```

Let's create the plan for this query using the following API command.
Copy, paste and execute the following.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT TIME_FLOOR(__time,'"'"'PT1m'"'"'), channel, COUNT(*) FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"' GROUP BY 1, 2"}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > groupby_plan.json
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's open the resulting plan file (named <i>groupby_plan.json</i>) in the editor.

<a href="#img-2">
  <img alt="Open GroupBy" src="../assets/OpenGroupBy.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Open GroupBy" src="../assets/OpenGroupBy.png" />
</a>

Notice the following about the plan:
- The value of the _queryType_ field is _groupBy_
- There is a new section in the query named _virtualColumns_ referring to the truncated timestamp
- The _granularity_ is _all_ instead of _MINUTE_, but the _context_ has a field named _timestampResultFieldGranularity_ set to _MINUTE_
- There is a new _dimensions_ array that refers to the truncated timestamp, and the channel columns
- There is a new _limitSpec_ field that indicates a noop, meaning Druid does not apply a limit

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Add a _LIMIT_ clause so we can inspect the impact on the _limitSpec_ field.
Back in the Shell, copy, paste and execute the following.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT TIME_FLOOR(__time,'"'"'PT1m'"'"'), channel, COUNT(*) FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"' GROUP BY 1, 2 LIMIT 100 "}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > groupby_plan_limit.json
```


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the editor, open the file named <i>groupby_plan_limit.json</i>.
Notice the effects of the _LIMIT_ clause on the _limitSpec_.

<h2 style="color:cyan">Superb! We see how the SQL GROUP BY clause affects the native query!</h2>


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
