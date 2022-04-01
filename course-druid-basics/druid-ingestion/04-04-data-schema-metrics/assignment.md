---
slug: 04-data-schema-metrics
id: 0xkwxpvjxpud
type: challenge
title: Data Schema Metrics
teaser: Create the dataSchema metrics for your table
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/3cvg1cs7mr
tabs:
- title: Shell
  type: terminal
  hostname: single-server
- title: Editor
  type: code
  hostname: single-server
  path: /root
difficulty: basic
timelimit: 750
---

Let's set up some metrics columns in our table.
Metrics columns allow us to do [_rollups_](https://druid.apache.org/docs/latest/tutorials/tutorial-rollup.html), which is where Druid combines several rows to aggregate metric columns.

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's take another look at an example record in the input data.

```
head --lines 1 /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json | jq
```

We'll use three columns as metrics: _added_, _deleted_ and _delta_.
We'll also add a _recordSum_ column that will tell us how many input records got rolled-up into our table row.

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the ingestion spec in the editor.

![Open the editor](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-ingestion/OpenSpec.png)

The [_metricsSpec_](https://druid.apache.org/docs/latest/ingestion/index.html#metricsspec) consists of a list of aggregators.
Each aggregator in the list has the following:
- _fieldName_ - the name of the field in the input record
- _name_ - the name of the column in the Druid table
- _type_ - the type of aggregation, here's a [list](https://druid.apache.org/docs/latest/querying/aggregations.html)

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Replace the empty _metricsSpec_ list with the following.

```
        "metricsSpec": [
            {
                "type": "count",
                "name": "recordSum"
            },
            {
                "fieldName": "added",
                "name": "addedSum",
                "type": "longSum"
            },
            {
                "fieldName": "deleted",
                "name": "deletedSum",
                "type": "longSum"
            },
            {
                "fieldName": "delta",
                "name": "deltaSum",
                "type": "longSum"
            }
        ],
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>recordSum has no fieldName because ingestion calculates this value by counting the number of combined records.</i></p>
<hr style="background-color:cyan">

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

![Save the file](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-ingestion/SaveFile.png)

<br>
<h2 style="color:cyan">Cool! Defining Druid metics columns is easy too!</h2>