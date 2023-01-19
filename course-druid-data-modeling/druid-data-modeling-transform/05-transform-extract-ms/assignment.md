---
slug: transform-extract-ms
id: qgdxe8enrhtt
type: challenge
title: Using Ingestion Transforms to Extract from Timestamp
teaser: Create new date dimension by using <i>__time</i>
notes:
- type: video
  url: ../assets/08-TransformExercise5.mp4
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

In the last exercise we created a transform by treating the raw data's timestamp value as a string.

In this exercise, we'll access the timestamp value as an actual timestamp.

As before, we will use the data that we created in a previous exercise.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's again review the data using the following command.

```
head -10 /root/raw_data.csv
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the editor, open the ingestion spec (_ingestion-spec.json_).

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's create a _milliseconds_ dimension that shows the number of milliseconds since the beginning of the last second.


We can calculate the number of milliseconds by using the <i>__time</i> value and using the modulus operator to strip off the last three decimal places (i.e., __time % 1000).


To create the _milliseconds_ dimension, you need to:
<ul>
  <li>Add a dimension to the <i>dimensionSpec</i> named <i>milliseconds</i></li>
  <li>Add a transform to the <i>transforms</i> list, which transforms the <i>__time</i> field values by performing the modulo operation</li>
</ul>

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
You want to add <i>milliseconds</i> to your <i>dimensionsSpec</i>:
<pre><code>"dimensionsSpec": {
    "dimensions": [
        "pid",
        "processName",
        "date",
        "milliseconds"
    ]
},
</code></pre>
Also, you want to add the following transform to the <i>transforms</i> list (don't forget the comma between transforms):
<pre><code>{
    "type": "expression",
    "name": "milliseconds",
    "expression": "__time % 1000"
}
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the file.

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the shell, ingest the data using the following command.

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

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

This query selects only the <i>__time</i> and _milliseconds_ columns.
Review the query results to see that the transform behaved correctly.

<h2 style="color:cyan">Bonus Step</h2><hr style="color:cyan;background-color:cyan;height:5px">

Want some extra fun?
Try creating a residual _seconds_ dimension using <i>__time</i>.

<details>
  <summary style="color:cyan"><b>Need some help?</b></summary>
<hr style="color:cyan">
You want to add <i>seconds</i> to your <i>dimensionsSpec</i>:
<pre><code>"dimensionsSpec": {
    "dimensions": [
        "pid",
        "processName",
        "date",
        "milliseconds",
        "seconds"
    ]
},
</code></pre>
Also, you want to add the following transform to the <i>transforms</i> list (don't forget the comma between transforms):
<pre><code>{
    "type": "expression",
    "name": "seconds",
    "expression": "(__time / 1000) % 60"
}
</code></pre>
Remember to save the file.
<br><br>
Also, open _query.json_ and modify the query to select the <i>seconds</i> dimension.
<br><br>
Save the file.
<br><br>
Then, rerun the ingestion and the query to verify your work.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Outstanding! You have transformed a timestamp as well as a string.</h2>
