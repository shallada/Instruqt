---
slug: unix-timestamps
id: m94zksx2owyo
type: challenge
title: Ingesting More Timestamps
teaser: Try to adjust the ingestion spec for some different data
notes:
- type: video
  url: ../assets/03-TimestampExercise2.mp4
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

Here's another chance to practice ingesting data.
Since we showed you how to do this in the last exercise, this exercise will be a bit less prescriptive.
We know you will love the challenge of doing it more on your own!

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We'll start by generating some more data with a slightly different format.
Again, this command takes 10+ seconds to execute.

```
/root/process-monitor-producer.sh Epoch 100 \
  > /root/unix_raw_data.csv
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's take a look at the data and see how it differs from the data in the previous exercise.

```
head -10 /root/unix_raw_data.csv
```

Note that the timestamp is no longer in ISO format.
Instead, the timestamp is the number of milliseconds since January 1, 1970 UTC (Unix Epoch time).

Let's create an ingestion spec for this new data format.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Start by making a copy of the previous ingestion spec.

```
cp ingestion-spec.json \
  unix-ingestion-spec.json
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Open the new copy of the ingestion spec in the editor and update the spec to work for this data.

You will need to make the following adjustments:
<ul>
  <li>Rename the table datasource table name to <i>unix-process-data</i></li>
  <li>Change input source (<i>filter</i>) for the raw data to <i>unix_raw_data.csv</i></li>
  <li>Change the timestamp format to work with the new timestamp values</li>
</ul>

Remember, the [docs](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#timestampspec) are very helpful.

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
The ingestion spec should now look like this:
<pre><code>{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "unix-process-data",
            "timestampSpec": {
                "column": "time",
                "format": "millis"
            },
            "dimensionsSpec": {
                "dimensions": [
                    "pid",
                    "process-name"
                ]
            },
            "metricsSpec": [
                { "type" : "floatSum", "name" : "cpu", "fieldName" : "cpu" },
                { "type" : "floatSum", "name" : "memory", "fieldName" : "memory" },
                { "type" : "count", "name" : "agg-count" }
            ],
            "granularitySpec": {
                "segmentGranularity": "day",
                "queryGranularity": "second",
                "rollup": true
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "local",
                "baseDir": "/root/",
                "filter": "unix_raw_data.csv"
            },
            "inputFormat": {
                "type": "csv",
                "findColumnsFromHeader": "true"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type" : "index_parallel",
            "maxRowsInMemory" : 25000,
            "maxBytesInMemory" : 250000,
            "partitionSpec" : {
              "type" : "dynamic",
              "maxRowsPerSegment" : 5000000
            }
        }
    }
}
</code></pre>
<hr style="color:cyan">
</details>


Be sure to save the file!

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the shell, ingest the data using the following command.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/unix-ingestion-spec.json \
  --url http://localhost:8081
# now wait for new segments to load
until curl localhost:8888/druid/coordinator/v1/datasources/unix-process-data/loadstatus?forceMetadataRefresh=true 2> /dev/null | \
  grep -q '"unix-process-data":100'
  do
    sleep 1
  done
```

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>If the ingestion fails, you can use the editor to review the log files in the folder here: /root/apache-druid-0.21.1/var/druid/indexing-logs/.
</i></p>

<details>
  <summary style="color:cyan"><b>What does the loop do after the ingest command?</b></summary>
<hr style="color:cyan">
The default Druid ingest script merely waits for segments to be available.
When we ingest new segments, the script does not distinguish between old segments and new ones.
This loop checks the status of the historical and waits for the new segments to load.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/unix-query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

Even though the raw data format was different, notice that the ingested data has the same format as the previous exercise including the truncated timestamps.

<h2 style="color:cyan">Wonderful! You now see how to adjust the timestamp format to match the raw data!</h2>
