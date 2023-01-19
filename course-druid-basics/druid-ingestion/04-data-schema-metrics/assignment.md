---
slug: data-schema-metrics
id: 0xkwxpvjxpud
type: challenge
title: Data Schema Metrics
teaser: Create the dataSchema metrics for your table
notes:
- type: video
  url: ../assets/04-splash.mp4
tabs:
- title: Shell
  type: terminal
  hostname: single-server
- title: Editor
  type: code
  hostname: single-server
  path: /root
difficulty: basic
timelimit: 600
---

Let's set up some metrics columns in our table.
Metrics columns allow us to do [_rollups_](https://druid.apache.org/docs/latest/tutorials/tutorial-rollup.html), which is where Druid combines several rows to aggregate metric columns.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's take another look at an example record in the input data.

```
head --lines 1 /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json | jq
```

We'll use three columns as metrics: _added_, _deleted_ and _delta_.
We'll also add a _recordSum_ column that will tell us how many input records got rolled-up into our table row.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the ingestion spec in the editor.

<a href="#img-2">
  <img alt="Open the editor" src="../assets/OpenSpec.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="Open the editor" src="../assets/OpenSpec.png" />
</a>

The [_metricsSpec_](https://druid.apache.org/docs/latest/ingestion/index.html#metricsspec) consists of a list of aggregators.
Each aggregator in the list has the following:
- _fieldName_ - the name of the field in the input record
- _name_ - the name of the column in the Druid table
- _type_ - the type of aggregation, here's a [list](https://druid.apache.org/docs/latest/querying/aggregations.html)

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

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

<a href="#img-4">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<a href="#" class="lightbox" id="img-4">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<h2 style="color:cyan">Cool! Defining Druid metics columns is easy too!</h2>

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
