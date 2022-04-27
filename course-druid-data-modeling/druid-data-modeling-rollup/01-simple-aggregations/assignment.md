---
slug: simple-aggregations
id: ya5wklihufma
type: challenge
title: Apply Precise Aggregators
teaser: Learn how to use simple aggregation to rollup rows
notes:
- type: video
  url: ../assets/13-RollupExercise1.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
difficulty: basic
timelimit: 600
---
In this exercise, we'll apply simple precise aggregation to some data.

If you have not already done so, you may want to check out the docs on _metricsSpec_ [here](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#metricsspec).


<details>
  <summary style="color:cyan"><b>Are you new to these exercises? Click here for instructions.</b></summary>
<hr style="color:cyan">
These exercises allow you to actually <i>do</i> the tasks involved in learning Druid within the comfort of your browser!<br><br>
Click on the command boxes to copy the commands to your clipboard.
Then, paste the commands in the terminal to execute them.<br><br>
Some of the steps of the exercise will require using browser tabs external to the exercise tab.
When necessary, the exercise will explain how to open these external tabs.
When working in other browser tabs, you will want to switch back and forth between the tabs.<br><br>
That's all there is to it! Enjoy!
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Again, let's create some raw data that we can ingest.

Run the following command to generate the data. This script will take 10+ seconds to run.

```
/root/process-monitor-producer.sh ISO 100 > /root/raw_data.csv
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's review some of the data we just ingested to remind us of the format.

```
head -10 /root/raw_data.csv \
   | column -t -s,
```


Observe the following about the data:
<ul>
  <li>The first field is an ISO formatted timestamp with millisecond granularity</li>
  <li>The second field contains the process ID</li>
  <li>The third field is a string that contains the process name</li>
  <li>The fourth field is a floating point value showing the CPU utilization</li>
  <li>The fifth field is also a floating point value showing the memory utilization</li>
</ul>

We want to rollup rows within a _second_ time interval for each process.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch to the editor tab.

<a href="#img-1">
  <img alt="Switch to editor" src="../assets/EditorTab.png" />
</a>

<a href="#" class="lightbox" id="img-1">
  <img alt="Switch to editor" src="../assets/EditorTab.png" />
</a>


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Open the ingestion spec file.

<a href="#img-2">
  <img alt="Open ingestion spec" src="../assets/OpenIngestionSpec.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="Open ingestion spec" src="../assets/OpenIngestionSpec.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by enabling rollup in the _granularitySpec_ (inside _dataSchema_).
Also, make sure _queryGranularity_ is set to _second_.

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
The granularity spec should look like this:
<pre><code>"granularitySpec": {
  "segmentGranularity": "day",
  "queryGranularity": "second",
  "rollup": true
}
</code></pre>
<hr style="color:cyan">
</details>

<br>
<details>
  <summary style="color:cyan"><b>What do these two settings do?</b></summary>
<hr style="color:cyan">
Setting <i>rollup</i> to true tells the Druid ingestion process to reference the <i>metricsSpec</i>.
Setting <i>queryGranularity</i> to <i>second</i> causes the ingestion process to truncate the millisecond portion of the timestamps.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Notice that the _metricsSpec_ is a list.
Within the _metricsSpec_, add a count metric and name it _count_.
You can review the docs [here](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#metricsspec).


<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
You want the <i>metricsSpec</i> list to look like this:
<pre><code>"metricsSpec": [
  { "type" : "count", "name" : "count" }
],
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, add more elements to the _metricsSpec_ list to get the sum, min and max of the _cpu_ and _memory_ fields.


<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
You want the <i>metricsSpec</i> list to look like this:
<pre><code>"metricsSpec": [
  { "type" : "count", "name" : "count" },
  { "type" : "floatSum", "name" : "cpu", "fieldName" : "cpu" },
  { "type" : "floatMin", "name" : "cpu_min", "fieldName" : "cpu" },
  { "type" : "floatMax", "name" : "cpu_max", "fieldName" : "cpu" },
  { "type" : "floatSum", "name" : "memory", "fieldName" : "memory" },
  { "type" : "floatMin", "name" : "memory_min", "fieldName" : "memory" },
  { "type" : "floatMax", "name" : "memory_max", "fieldName" : "memory" }
],
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the file by clicking the _save_ icon.

<a href="#img-3">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<a href="#" class="lightbox" id="img-3">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>


<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Your ingestion spec is now ready, so switch back to the Shell tab.

<a href="#img-4">
  <img alt="Switch to shell" src="../assets/ShellTab.png" />
</a>

<a href="#" class="lightbox" id="img-4">
  <img alt="Switch to shell" src="../assets/ShellTab.png" />
</a>

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Ingest the data using the following command.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
```

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>If the ingestion fails, you can use the editor to review the log files in the folder here: /root/apache-druid-0.21.1/var/druid/indexing-logs/.
</i></p>

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data to see what it looks like.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | jq
```

Notice the various columns including the _count_ column which indicates how many raw data rows have been rolled up.

<h2 style="color:cyan">Look at that! You've done some rollup!</h2>

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
