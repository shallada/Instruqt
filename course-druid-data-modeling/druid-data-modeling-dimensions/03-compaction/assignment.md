---
slug: compaction
id: mxcqs7luvotg
type: challenge
title: Compaction for Schema Changes
teaser: Use compaction to modify the schema for existing data
notes:
- type: video
  url: ../assets/12-DimensionsExercise3.mp4
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

In the previous exercises, when we wanted to change our schema, we re-ingested the original data.

In this exercise, we'll show you how to change the schema without accessing the original data.
This exercise will have the same result as the previous exercise, but we will get there using manual compaction instead of re-ingestion.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Again, let's set up the lab by performing a schemaless ingestion.

Switch to the editor tab and look at the ingestion spec (ingestion-spec.json) to verify the _dimensionsSpec_ is empty.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Once you have reviewed the ingestion spec, switch back to the shell and ingest the data using the following command.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data to see what it looks like.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
# now wait for new segments to load
until curl localhost:8888/druid/coordinator/v1/datasources/process-data/loadstatus?forceMetadataRefresh=true 2> /dev/null | \
  grep -q '"process-data":100'
  do
    sleep 1
  done
```

Notice that the data consists of five columns (including <i>__time</i>, _processName_, _pid_, _cpu_, and _memory_).

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>It may take a minute or so for the system schema to update.
If you don't see the pid column, wait a minute and re-execute the query. Eventually, the pid column will appear.
</i></p>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

We'll use manual compaction to eliminate the _pid_ column.

To do so, we'll use a compaction spec.
Open _compaction-spec.json_ in the editor.

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Notice that the compaction spec looks similar in some ways to an ingestion spec, but also notice the differences.
You can find more about manual compaction [here](https://druid.apache.org/docs/latest/ingestion/compaction.html#setting-up-manual-compaction).

In the compaction spec, create a _dimensionsSpec_ that contains the list of columns we want to retain (i.e., _processName_, _cpu_, and _memory_).

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
Here's what your <i>dimensionsSpec</i> should look like:
<pre><code>"dimensionsSpec": {
    "dimensions": [
        "processName",
        "cpu",
        "memory"
    ]
}</code></pre>
<hr style="color:cyan">
</details>

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>For manual compaction, if you include a dimensionsSpec, it must include a dimensions list containing exactly those columns you wish to retain. You cannot use an exclusion list for compaction. If you completely omit the dimensionsSpec, all columns will be retained from the source segments.
</i></p>


<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Be sure to save the file.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the shell, perform the compaction.


```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/compaction-spec.json \
  --url http://localhost:8081
# now wait for new segments to load
until curl localhost:8888/druid/coordinator/v1/datasources/process-data/loadstatus?forceMetadataRefresh=true 2> /dev/null | \
  grep -q '"process-data":100'
  do
    sleep 1
  done
```

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>If the ingestion fails, you can use the editor to review the log files in the folder here: /root/apache-druid-0.21.1/var/druid/indexing-logs/.
</i></p>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, let's perform the query again to verify that _pid_ is no longer a dimension.

```
curl -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>It may take a minute or so for the system schema to update.
If you still see the pid column, wait a minute and re-execute the query. Eventually, the pid column will disappear.
</i></p>

<h2 style="color:cyan">Wonderful! You know how to use compaction to change your schema.</h2>
