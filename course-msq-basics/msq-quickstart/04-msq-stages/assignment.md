---
slug: msq-stages
id: dc2periosrws
type: challenge
title: Multi-Stage Query Framework Stages
teaser: Learn how the stages of the MSQ framework work together
notes:
- type: video
  url: ../assets/04-MSQStages.mp4
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
timelimit: 900
---

<h2 style="color:cyan">Investigate the MSQ framework stages using parallelism</h2>


<details>
  <summary style="color:cyan"><b>I want the backstory for this lab!</b></summary>
<hr style="background-color:cyan">
We want to understand a bit more about the architecture and operation of the Multi-Stage Query framework.
So in this lab, we'll perform an ingestion that has several stages (due to the <i>GROUP BY</i> clause and the second <i>SELECT</i> clause).
We will also enable some parallelism among the worker tasks.
<br><br>
Once we have completed the ingestion, we will review the report of the stages and workers that performed the ingestion.
<hr style="background-color:cyan">
</details>


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

Open a new query tab.

<details>
  <summary style="color:cyan"><b>Why do I need a new query tab?</b></summary>
<hr style="background-color:cyan">
Strictly speaking, you don't <i>need</i> a new tab for this query.
But, sometimes it's helpful to be able to use multiple tabs for various operations so you can refer back to previous operations and their results.
<hr style="background-color:cyan">
</details>

<a href="#img-3">
  <img alt="Add Query Tab" src="../assets/AddQueryTab.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Add Query Tab" src="../assets/AddQueryTab.png" />
</a>


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Copy and paste the following ingestion query.

```
INSERT INTO wiki_stages

WITH langs AS (
  SELECT *
  FROM TABLE(
    EXTERN(
      '{"type": "local", "baseDir": "/root", "filter": "langs.json"}',
      '{"type": "json"}',
      '[{"name": "channel", "type": "string"}, {"name": "language", "type": "string"}]'
    )
  )
),

wiki AS (
  SELECT *
  FROM TABLE(
    EXTERN(
      '{"type": "http", "uris": ["https://static.imply.io/gianm/wikipedia-2016-06-27-sampled.json"]}',
      '{"type": "json"}',
      '[{"name": "added", "type": "long"}, {"name": "channel", "type": "string"}, {"name": "cityName", "type": "string"}, {"name": "comment", "type": "string"}, {"name": "commentLength", "type": "long"}, {"name": "countryIsoCode", "type": "string"}, {"name": "countryName", "type": "string"}, {"name": "deleted", "type": "long"}, {"name": "delta", "type": "long"}, {"name": "deltaBucket", "type": "string"}, {"name": "diffUrl", "type": "string"}, {"name": "flags", "type": "string"}, {"name": "isAnonymous", "type": "string"}, {"name": "isMinor", "type": "string"}, {"name": "isNew", "type": "string"}, {"name": "isRobot", "type": "string"}, {"name": "isUnpatrolled", "type": "string"}, {"name": "metroCode", "type": "string"}, {"name": "namespace", "type": "string"}, {"name": "page", "type": "string"}, {"name": "regionIsoCode", "type": "string"}, {"name": "regionName", "type": "string"}, {"name": "timestamp", "type": "string"}, {"name": "user", "type": "string"}]'
    )
  )
  LIMIT 100
)

SELECT
  FLOOR(TIME_PARSE(wiki."timestamp") TO HOUR) AS __time,
  wiki.page,
  wiki."channel",
  langs."language",
  SUM(wiki.added) sum_added,
  SUM(wiki.deleted) sum_deleted
FROM wiki
LEFT JOIN langs ON wiki.channel = langs.channel
GROUP BY 1,2,3,4
PARTITIONED BY DAY
CLUSTERED BY "page"
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>This ingestion contains a JOIN clause.
The MSQ framework can perform "broadcast joins", which are joins where only one of the tables is relatively large.
Other tables included within a broadcast join must be small enough to fit into memory.
Full "shuffle joins" (i.e., joins between two or more large tables) will be available in a future release of the framework.</i></p>
<hr style="background-color:cyan">

<details>
  <summary style="color:cyan"><b>What does <i>GROUP BY<i/> do during ingestion?</b></summary>
<hr style="background-color:cyan">
The <i>GROUP BY<i/> clause, when used during ingestion, tells Druid to aggregate rows.
Notice in the <i>SELECT<i/> clause the use of <i>FLOOR(...TO HOUR)<i/>, which truncates the values of the timestamps to hours.
Then, the <i>GROUP BY<i/> clause allows rows within the same hour and <i>page<i/> value to be aggregated (i.e., Druid sums <i>added<i/> and <i>deleted<i/> values).
<hr style="background-color:cyan">
</details>

<br>
<details>
  <summary style="color:cyan"><b>What does <i>CLUSTERED BY<i/> do during ingestion?</b></summary>
<hr style="background-color:cyan">
The <i>CLUSTERED BY<i/> clause specifies secondary partitioning of segments.
You can read about secondary partitioning <a href="https://druid.staged.apache.org/docs/latest/ingestion/partitioning.html#secondary-partitioning" target="_blank">here</a>.
When you know the main dimensions that users will use to query, you can use these for secondary partitioning.
Secondary partitioning is useful because it improves locality which increases query performance.
<hr style="background-color:cyan">
</details>

<a href="#img-4">
  <img alt="Paste Stage Query" src="../assets/PasteStageQuery.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Paste Stage Query" src="../assets/PasteStageQuery.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Increase the task parallelism to 1 controller and 3 max worker tasks.

<a href="#img-5">
  <img alt="Set Parallelism to 3" src="../assets/SetParallel2.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Set Parallelism to 3" src="../assets/SetParallel2.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Run the query.

<a href="#img-6">
  <img alt="Run Stage Query" src="../assets/RunStageQuery.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Run Stage Query" src="../assets/RunStageQuery.png" />
</a>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Once the ingestion is complete, click _Show details_.

<a href="#img-7">
  <img alt="Click Show Details" src="../assets/ClickShowStats.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Click Show Details" src="../assets/ClickShowStats.png" />
</a>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

See how SQL-based ingestion uses multiple stages.

You see the following six stages of the ingestion:
- <b>Stage0 scan</b> - Reads the wiki data input from an external file and creates a single partition
- <b>Stage1 limit</b> - Reads the partition created by S0 and performs the limit operation
- <b>Stage2 scan</b> - Reads the input from _langs.json_ and creates partitions
- <b>Stage3 groupByPreShuffle</b> - Reads all the partitions created by previous stages, performs preliminary grouping for a subset of the data, performs the _JOIN_, and creates partitions
- <b>Stage4 groupByPostShuffle</b> - Performs the _GROUP BY_ operation on each of the partitions
- <b>Stage5 segmentGenerator</b> - Creates segments in deep storage from the partitions

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:2px">

You can expand the stage summary to see the stage details.

<a href="#img-9">
  <img alt="Report S0 Details" src="../assets/ReportS0Details.png" />
</a>
<a href="#" class="lightbox" id="img-9">
  <img alt="Report S0 Details" src="../assets/ReportS0Details.png" />
</a>

The details show the workers that performed the stage, the amount of data they processed, and the partitions they created.


<h2 style="color:cyan">Amazing! You see how SQL-based ingestion gets great performance!</h2>


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
