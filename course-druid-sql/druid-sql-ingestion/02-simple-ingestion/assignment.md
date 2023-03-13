---
slug: simple-ingestion
id: rdmh9ibqn7ls
type: challenge
title: Simple Druid SQL-based Ingestion
teaser: Use SQL-based ingestion to perform a simple ingestion using  familiar SQL!
notes:
- type: video
  url: ../assets/02-SimpleIngestion.mp4
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

<h2 style="color:cyan">Use SQL to perform an ingestion.</h2>

We will redirect the output from the query in the previous activity to a Druid datasource.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Druid Console_ tab.

<a href="#img-1">
  <img alt="Click Druid Console" src="../assets/ClickDruidConsole.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Click Druid Console" src="../assets/ClickDruidConsole.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Query_ tab.

<a href="#img-2">
  <img alt="Click Query Tab" src="../assets/ClickQueryTab.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Click Query Tab" src="../assets/ClickQueryTab.png" />
</a>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Modify the query from the previous lab by adding the following line to the top of the query.

<details>
  <summary style="color:cyan"><b>What does this do?</b></summary>
<hr style="background-color:cyan">
The <i>INSERT INTO...</i> clause specifies an ingestion by telling Druid to take the results from the query following the clause, and redirect them to the named table datasource.
<hr style="background-color:cyan">
</details>

```
INSERT INTO wikipedia
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Change the _SELECT_ clause to look as follows.

<details>
  <summary style="color:cyan"><b>What does this do?</b></summary>
<hr style="background-color:cyan">
Generally speaking, the <i>SELECT</i> clause determines which columns the results contain.
This specific <i>SELECT</i> clause identifies the <i>__time</i> column and all the remainder of the columns from the input as columns that will be in the results (i.e., ingested into the Druid table datasource).
<br><br>
Note that using <i>SELECT TIME_PARSE("timestamp") AS __time, *</i> would select the <i>timestamp</i> column twice, and is therefore an anti-pattern. Instead, we explicitly list all the column names.
<br><br>
All Druid table datasources must have a column named <i>__time</i>.
The <i>TIME_PARSE()</i> operator converts the <i>timestamp</i> field values to the correct format for the <i>__time</i> column.
<hr style="background-color:cyan">
</details>

```
SELECT
  TIME_PARSE("timestamp") AS __time,
  isRobot,
  channel,
  flags,
  isUnpatrolled,
  page,
  diffUrl,
  added,
  comment,
  commentLength,
  isNew,
  isMinor,
  delta,
  isAnonymous,
  user,
  deltaBucket,
  deleted,
  namespace,
  cityName,
  countryName,
  regionIsoCode,
  metroCode,
  countryIsoCode,
  regionName
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Modify the query again by replacing the _LIMIT_ line with the following line.

<details>
  <summary style="color:cyan"><b>What does this do?</b></summary>
<hr style="background-color:cyan">
We eliminate the <i>LIMIT BY</i> clause because we want to ingest all the data from the external file.
<br><br>
Druid stores data in segments.
Segments have a <i>granularity</i> which determines which rows are stored within a segment.
The <i>PARTIONED BY...</i> clause tells Druid the size of the segment granularity.
In this case the segment granularity will be a day long, but you could use other values like <i>HOUR</i>, or <i>WEEK</i>.
See the <a href="https://druid.apache.org/docs/latest/querying/granularities.html#simple-granularities" target="_blank">docs</a> for more details.
<hr style="background-color:cyan">
</details>

```
PARTITIONED BY DAY
```

<details>
  <summary style="color:cyan"><b>What should the final query look like?</b></summary>
<hr style="background-color:cyan">
<pre>
INSERT INTO wikipedia
SELECT
  TIME_PARSE("timestamp") AS __time,
  isRobot,
  channel,
  flags,
  isUnpatrolled,
  page,
  diffUrl,
  added,
  comment,
  commentLength,
  isNew,
  isMinor,
  delta,
  isAnonymous,
  user,
  deltaBucket,
  deleted,
  namespace,
  cityName,
  countryName,
  regionIsoCode,
  metroCode,
  countryIsoCode,
  regionName
FROM TABLE(
  EXTERN(
    '{"type": "http", "uris": ["https://static.imply.io/gianm/wikipedia-2016-06-27-sampled.json"]}',
    '{"type": "json"}',
    '[{"name": "added", "type": "long"}, {"name": "channel", "type": "string"}, {"name": "cityName", "type": "string"}, {"name": "comment", "type": "string"}, {"name": "commentLength", "type": "long"}, {"name": "countryIsoCode", "type": "string"}, {"name": "countryName", "type": "string"}, {"name": "deleted", "type": "long"}, {"name": "delta", "type": "long"}, {"name": "deltaBucket", "type": "string"}, {"name": "diffUrl", "type": "string"}, {"name": "flags", "type": "string"}, {"name": "isAnonymous", "type": "string"}, {"name": "isMinor", "type": "string"}, {"name": "isNew", "type": "string"}, {"name": "isRobot", "type": "string"}, {"name": "isUnpatrolled", "type": "string"}, {"name": "metroCode", "type": "string"}, {"name": "namespace", "type": "string"}, {"name": "page", "type": "string"}, {"name": "regionIsoCode", "type": "string"}, {"name": "regionName", "type": "string"}, {"name": "timestamp", "type": "string"}, {"name": "user", "type": "string"}]'
  )
)
PARTITIONED BY DAY
</pre>
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Run_ button to ingest the data and create a Druid table datasource named _wikipedia_.

<a href="#img-6">
  <img alt="Run Ingestion" src="../assets/RunIngestion.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Run Ingestion" src="../assets/RunIngestion.png" />
</a>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Once Druid completes the ingestion from the previous step, we can run an example query against the _wikipedia_ datasource.
Run the example query as follows.

<a href="#img-7">
  <img alt="Run Select All" src="../assets/RunSelectAll.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Run Select All" src="../assets/RunSelectAll.png" />
</a>


<h2 style="color:cyan">Sweet! You have ingested data using SQL-based ingestion and have queried the data to verify the ingestion!</h2>


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
