---
slug: scan
id: k7kpdmgjvsvn
type: challenge
title: Druid SQL Explain Plan Scan
teaser: Let's see SQL queries that Druid translates into scan queries
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

In this exercise, let's investigate SQL queries that map to Native Scan queries.
These queries do NOT perform aggregation.
Read more about Scan queries <a href="https://druid.apache.org/docs/latest/querying/scan-query.html" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start with the simplest Druid SQL query.
Consider the following query that merely selects all columns within a specified time range.

```
SELECT *
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2016-06-27 00:00:00'
  AND TIMESTAMP '2016-06-28 00:00:00'
```

We could paste this query in the Druid Console, prepend a _EXPLAIN PLAN FOR_ clause in front and run the query to see the Native query.
But instead, let's use the API to run the query so we can redirect the output into a file we can investigate.


In the _Shell_, run the following command, which isolates the _PLAN_ section of the returned results and formats the output.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT * FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"'"}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > /root/scan_plan_simple.json
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Open the resulting file named <i>scan_plan_simple.json</i> in the editor so we can inspect the plan.

<a href="#img-2">
  <img alt="Open Plan" src="../assets/OpenPlan.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Open Plan" src="../assets/OpenPlan.png" />
</a>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Collapse the top-level elements (i.e., _query_ and _signature_).

<a href="#img-3">
  <img alt="Collapse Top" src="../assets/CollapseTop.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Collapse Top" src="../assets/CollapseTop.png" />
</a>

We see that there are two top-level elements:
- _query_ which is an object that defines the Native query
- _signature_ which is an array that describes the data types of the returned columns


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's familiarize ourselves with the elements of the object.


Expand the query object, but collapse its elements.


<a href="#img-4">
  <img alt="Expand Query" src="../assets/ExpandQuery.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Expand Query" src="../assets/ExpandQuery.png" />
</a>

We can see the elements that make up the native query.
Let's look at each of these elements, one by one.


The first thing we notice is the _queryType_ field that has a value of _scan_.
Non-aggregating queries are _scan_ queries.

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's expand the _datasource_ element.

<a href="#img-5">
  <img alt="Expand Datasource" src="../assets/ExpandDatasource.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Expand Datasource" src="../assets/ExpandDatasource.png" />
</a>

We see that the _datasource_ element maps to the _FROM_ clause.
Read more <a href="https://druid.apache.org/docs/latest/querying/datasource.html" target="_blank">here</a>.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, let's expand the _intervals_.

<a href="#img-6">
  <img alt="Expand Intervals" src="../assets/ExpandIntervals.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Expand Intervals" src="../assets/ExpandIntervals.png" />
</a>

The intervals map to the _WHERE_ clause.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

The _resultFormat_ determines the way Druid will format the returned data.


Let's expand _columns_.

<a href="#img-7">
  <img alt="Expand Columns" src="../assets/ExpandColumns.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Expand Columns" src="../assets/ExpandColumns.png" />
</a>

This _columns_ array is a list of columns from the _SELECT_ clause.
Druid translated the star (*) into an explicit enumeration of all columns in the table datasource.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

We see that _legacy_ is set to _false_.
Legacy queries use a depreciated query format that is not very interesting any more.
Read more <a href="https://druid.apache.org/docs/latest/querying/scan-query.html#legacy-mode" target="_blank">here</a>.

Next, let's expand the _context_.

<a href="#img-8">
  <img alt="Expand Context" src="../assets/ExpandContext.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Expand Context" src="../assets/ExpandContext.png" />
</a>

We see the _context_ contains query IDs that we could use to correlate with the log files if we have enabled query logging.
Read more <a href="https://druid.apache.org/docs/latest/operations/request-logging.html" target="_blank">here</a>.


The _granularity_ element allows us to set the Query Granularity, which doesn't really apply to Scan queries.
Read more <a href="https://druid.apache.org/docs/latest/querying/granularities.html" target="_blank">here</a>.


<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's change the _SELECT_ clause in the query to look as follows.

```
SELECT __time, channel
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2016-06-27 00:00:00'
  AND TIMESTAMP '2016-06-28 00:00:00'
```

Back in the shell, run the following command to create a query plan for this query.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT __time, channel FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"'"}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > /root/scan_plan_select.json
```

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the editor, open the file named <i>scan_plan_select.json</i>.


Inspect the file and notice how the _signature_ and _query.columns_ elements have changed to reflect the changes made to the SQL _SELECT_ clause.


<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, let's modify the _WHERE_ clause so that the query looks as follows.

```
SELECT __time, channel
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2016-06-27 00:00:00'
  AND TIMESTAMP '2016-06-28 00:00:00'
  AND channel = '#en.wikipedia'
```

In the shell, run this command to create a plan for this query.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT __time, channel FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"' AND channel = '"'"'#en.wikipedia'"'"'"}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > /root/scan_plan_where.json
```

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the editor, open the file named <i>scan_plan_where.json</i>.


Inspect the _query.filter_ element to see how it reflects the part of the _WHERE_ clause that we modified.

Read more <a href="https://druid.apache.org/docs/latest/querying/filters.html" target="_blank">here</a>.

<h2 style="color:cyan">Super! We have issued non-aggregating queries and understand how the SQL maps to the native query format!</h2>


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
