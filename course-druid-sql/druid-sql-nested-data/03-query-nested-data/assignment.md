---
slug: query-nested-data
id: xgu5pjgdtqee
type: challenge
title: Query Nested Data
teaser: Let's query the nested data
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

In the previous exercise, we ingested some nested data.
Now, let'ssee how we can query the nested data.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open a new _Query_ tab as shown.

<a href="#img-1">
  <img alt="New Query Tab" src="../assets/NewQueryTab.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="New Query Tab" src="../assets/NewQueryTab.png" />
</a>


<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Paste the following query, and execute the query as shown.

<details>
  <summary style="color:cyan"><b>Why do we use a time filter for this query?</b></summary>
<hr style="background-color:cyan">
Druid stores data within segments based on time intervals.
By specifying a time filter, Druid is able to quickly narrow down which segments to consider for the query.
Without a time filter, Druid would need to scan all segments associated with the table datasource, which would consume a lot of time and resources for large production tables.
Read more <a href="https://druid.apache.org/docs/latest/design/segments.html" target="_blank">here</a>.
<br><br>
In this query, the time filter doesn't narrow the results, but we use the time filter to reinforce best practices.
<hr style="background-color:cyan">
</details>


```
SELECT __time,
  product,
  price,
  JSON_VALUE(ShippingInfo, '$.first_name') as first_name,
  JSON_VALUE(ShippingInfo, '$.last_name') as last_name,
  JSON_VALUE(ShippingInfo, '$.address.city') as city
FROM nested_data
WHERE __time BETWEEN TIMESTAMP '2023-01-01 00:00:00'
  AND TIMESTAMP '2033-01-01 00:00:00'
```

<a href="#img-2">
  <img alt="Run Simple Query" src="../assets/RunSimpleQuery.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Run Simple Query" src="../assets/RunSimpleQuery.png" />
</a>


Notice how we selected the nested data values using the <i>JSON_VALUE()</i> function.
Read more <a href="https://druid.apache.org/docs/latest/querying/nested-columns.html#querying-nested-columns" target="_blank">here</a>.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

We can also use the <i>JSON_VALUE()</i> function in the _WHERE_ clause.


Let's change the query's _WHERE_ clause.
Replace the query with the following and execute the query.

```
SELECT __time,
  product,
  price,
  JSON_VALUE(ShippingInfo, '$.first_name') as first_name,
  JSON_VALUE(ShippingInfo, '$.last_name') as last_name,
  JSON_VALUE(ShippingInfo, '$.address.city') as city
FROM nested_data
WHERE __time BETWEEN TIMESTAMP '2023-01-01 00:00:00'
  AND TIMESTAMP '2033-01-01 00:00:00'
  AND JSON_VALUE(ShippingInfo, '$.address.city') = 'Tokyo'
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Recall that SQL evaluates the WHERE clause before the SELECT clause.
Therefore, we may not refer to the city column, but instead must use the JSON_VALUE() function.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

We can unpack the nested data during ingestion using the same <i>JSON_VALUE()</i> function.
Open a new query tab and paste and execute the following ingestion query.

```
REPLACE INTO "unnested_data" OVERWRITE ALL
WITH "ext" AS (SELECT *
FROM TABLE(
  EXTERN(
    '{"type":"local","baseDir":"/root","filter":"nested_data.json"}',
    '{"type":"json"}',
    '[{"name":"timestamp","type":"string"},{"name":"product","type":"string"},{"name":"price","type":"double"},{"name":"ShippingInfo","type":"COMPLEX<json>"}]'
  )
))
SELECT
  TIME_PARSE("timestamp") AS "__time",
  "product",
  "price",
  JSON_VALUE(ShippingInfo, '$.first_name') as first_name,
  JSON_VALUE(ShippingInfo, '$.last_name') as last_name,
  JSON_VALUE(ShippingInfo, '$.address.city') as city
FROM "ext"
PARTITIONED BY DAY
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Use the following query to inspect the unnested data.
Paste the following into a new query tab and execute the query.

```
SELECT * FROM "unnested_data" LIMIT 3
```

Notice that the <i>first_name</i>, <i>last_name</i>, and <i>city</i> columns are no longer nested.

In this exercise, we have focused on the <i>JSON_VALUE()</i> function, but there are many more JSON-related functions.
Read more <a href="https://druid.apache.org/docs/latest/querying/sql-json-functions.html" target="_blank">here</a>.

<h2 style="color:cyan">Excellent! We see how to use JSON functions to manipulate nested data!</h2>


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
