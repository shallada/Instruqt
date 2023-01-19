---
slug: shadow-transforms
id: b3nlcaxa0k4j
type: challenge
title: Using Ingestion Transforms - Try It Yourself
teaser: Try to adjust the ingestion spec to modify the transform
notes:
- type: video
  url: ../assets/06-TransformExercise3.mp4
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

So far when changing the process name, we have transformed raw data into a new dimension.

In this exercise, we'll apply a transform to data from an existing dimension and replace the original values.

Again, we will re-ingest the data that we created in the previous exercise.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Inspect the data using the following command to remind ourselves of its format.

```
head -10 /root/raw_data.csv
```

As we can see, the raw data's process name field is _processName_.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's change the transform that creates the _upperProcessName_ to a transform that updates the existing raw data _processName_ column instead.

Open the ingestion spec (_ingestion-spec.json_) in the editor and update the spec to make the change.

You will need to make the following adjustments:
<ul>
  <li>Change the transform's name field from <i>upperProcessName</i> to <i>processName</i></li>
  <li>Change the entry in the <i>dimensionsSpec</i> from <i>upperProcessName</i> to <i>processName</i></li>
</ul>


<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
Change the <i>transformSpec</i> to look as follows:
<pre><code>"transformSpec": {
  "transforms": [
    {
      "type": "expression",
      "name": "processName",
      "expression": "concat(upper(substring(processName,0,1)),substring(processName,1,strlen(processName)-1))"
    }
  ]
},
</code></pre>
Also, change the <i>dimensionsSpec</i> to look like this:
<pre><code>"dimensionsSpec": {
    "dimensions": [
        "pid",
        "processName"
    ]
},
</code></pre><hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the file.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

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

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

You should see that we have transformed the _processName_ field in place.
The [docs](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#transformspec) refer to this as _shadowing_.

<h2 style="color:cyan">Excellent! You have performed a transform in place.</h2>
