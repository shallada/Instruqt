---
slug: schemaless
id: nltjuvo46g8q
type: challenge
title: Use Schemaless Ingestion
teaser: Druid can intuit your schema for you. Want to see how?
notes:
- type: video
  url: ../assets/11-DimensionsExercise2.mp4
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

In the previous exercise we learned how to directly specify the dimensions in the Druid table datasource using the _dimensionsSpec_.

In this exercise we'll experiment with schemaless ingestion where Druid will determine the dimensions and their types automatically.

If you have not already done so, you may want to check out the docs on _dimensionsSpec_ [here](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#dimensionsspec).

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We'll use the same data we created in the previous exercise.
You can review a sample of the data with the following command.

```
head -10 /root/raw_data.csv \
   | column -t -s,
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

For schemaless ingestion, we can use an empty _dimensionsSpec_.

Switch to the editor tab and look at the ingestion spec (ingestion-spec.json) to verify the _dimensionsSpec_ is empty.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Once you have reviewed the ingestion spec, switch back to the shell and ingest the data using the following command.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
# now wait for new segments to load
until curl localhost:8888/druid/coordinator/v1/datasources/process-data/loadstatus?forceMetadataRefresh=true 2> /dev/null | \
  grep -q '"process-data":100'
  do
    sleep 1
  done
```

<details>
  <summary style="color:cyan"><b>What does the loop do after the ingest command?</b></summary>
<hr style="color:cyan">
The default Druid ingest script merely waits for segments to be available.
When we ingest new segments, the script does not distinguish between old segments and new ones.
This loop checks the status of the historical and waits for the new segments to load.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data to see what it looks like.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

Notice that only raw data fields were included as dimensions, and none of the transform dimensions were included.

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>It may take a minute or so for the system schema to update.
If you still see the transform columns, wait a minute and re-execute the query. Eventually, the transform columns will disappear.
</i></p>


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Really, the _pid_ dimension is pretty useless.
The _pid_ is an arbitrary transient process ID assigned by the operating system.


What if we didn't want _pid_, but we still want to use schemaless ingestion?

In this case we can create a _dimensionsSpec_ containing exclusions.
You can read more about exclusions [here](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#inclusions-and-exclusions).

Open the editor and modify the _dimensionsSpec_ to exclude _pid_.

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
The dimensions spec should look like this:
<pre><code>"dimensionsSpec" : {
  "dimensionExclusions": [
    "pid"
  ]
}
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Be sure to save the file.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the shell, re-ingest the raw data.

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>In the ingestion spec, we specified appendToExisting as false.
So when we re-ingest, all of the table datasource data gets replaced.
</i></p>


```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
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

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>Because we are re-ingesting, it may take a minute or so for the system schema to update.
If you still see the pid column, wait a minute and re-execute the query. Eventually, the pid column will disappear.
</i></p>

<h2 style="color:cyan">Great! You know how to use schemaless ingestion.</h2>
