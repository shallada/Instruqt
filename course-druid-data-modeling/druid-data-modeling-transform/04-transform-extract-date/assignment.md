---
slug: transform-extract-date
id: pbasdikbvwfw
type: challenge
title: Using Ingestion Transforms to Extract a Date Value
teaser: Create new date dimension
notes:
- type: video
  url: ../assets/07-TransformExercise4.mp4
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

Now that we've learned about transforms, let's look at a special case - timestamp transforms.

Suppose you want to have an additional dimension that contains only the date values instead of the entire timestamp.
For example, your query results may only need the date portion of the timestamp, so we want to apply Principle 2: Transform data, as much as possible, before storage.

Again, we will use the data that we created in a previous exercise.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's inspect the data using the following command.

```
head -10 /root/raw_data.csv
```

Note specifically the name of the column containing the timestamp, and that the date consists of the first 10 characters of the timestamp string.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the editor, open the ingestion spec (_ingestion-spec.json_).

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Add a transform to create a _date_ dimension.
You need to:
<ul>
  <li>Add a dimension to the <i>dimensionSpec</i> named <i>date</i></li>
  <li>Add a transform to the <i>transforms</i> list, which transforms the raw <i>time</i> field values by extracting only the date portion of the timestamps</li>
</ul>

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
<br>
You want to add <i>date</i> to your <i>dimensionsSpec</i>:
<pre><code>"dimensionsSpec": {
    "dimensions": [
        "pid",
        "processName",
        "date"
    ]
},
</code></pre>
Also, you want to add the following transform to the <i>transforms</i> list (don't forget the comma between transforms):
<pre><code>{
    "type": "expression",
    "name": "date",
    "expression": "substring(time,0,10)"
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

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

This query selects only the <i>__time</i> and _date_ columns.
Review the query results to see that the transform behaved correctly.


<h2 style="color:cyan">Good Job! You have extracted the date from the raw timestamp string.</h2>
