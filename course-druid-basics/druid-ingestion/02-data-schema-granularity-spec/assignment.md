---
slug: data-schema-granularity-spec
id: yibai6rcscm2
type: challenge
title: Defining timestampSpec and granularitySpec
teaser: Begin to explore the dataSchema with the granularitySpec
notes:
- type: video
  url: ../assets/02-splash.mp4
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
In the previous challenge, we looked at the ioConfigSpec.
In this challenge we introduce the [_dataSchema_](https://druid.apache.org/docs/latest/ingestion/index.html#dataschema) and dig into the [_timestampSpec_](https://druid.apache.org/docs/latest/ingestion/index.html#timestampspec) and [_granularitySpec_](https://druid.apache.org/docs/latest/ingestion/index.html#granularityspec).

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's review what our data looks like.

```
head --lines 1 /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json | jq
```

Make mental note of the _time_ field and its format.
You will see later how we will use this.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the ingestion spec in the editor.

<a href="#img-2">
  <img alt="Open the editor" src="../assets/OpenSpec.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="Open the editor" src="../assets/OpenSpec.png" />
</a>

Let's expand the dataSchema section of the ingestionSpec.
The dataSchema section contains five objects.
- _dataSource_ - the name of the Druid table
- _timestampSpec_ - describes how to ingest the time field
- _dimensionSpec_ - describes the dimension columns within the table
- _metricsSpec_ - describes the columns in the table that are metric types
- _granularitySpec_ - specifies the time precision, segment interval, etc.


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Replace the empty _dataSchema_ section in the editor with the _dataSchema_ outline below.

```
      "dataSchema" : {
        "dataSource" : "wikipedia",
        "timestampSpec" : {},
        "dimensionsSpec" : {},
        "metricsSpec" : [],
        "granularitySpec" : {}
      },

```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>The dataSource field has a value of "wikipedia".
This is how we specify the name of the table where we will place the ingested the data.</i></p>
<hr style="background-color:cyan">


In this challenge we will fill out the contents of the _timestampSpec_ and _granularitySpec_ sections of _dataSchema_.


The [_timestampSpec_](https://druid.apache.org/docs/latest/ingestion/index.html#timestampspec) contains the following.
- _column_ - the input record field containing the primary timestamp
- _format_ - describes the input timestamp format (see the [docs](https://druid.apache.org/docs/latest/ingestion/index.html#timestampspec) for possible values)
- _missingValue_ - this is the value used for records with missing timestamps

We'll use the following _timestampSpec_.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Replace the empty _timestampSpec_ with the following.

```
        "timestampSpec" : {
          "column" : "time",
          "format" : "auto"
        },
```

We don't have any missing timestamps in our input data, so we don't include the _missingValue_ field.

Now, let's fill out the [_granularitySpec_ ](https://druid.apache.org/docs/latest/ingestion/index.html#granularityspec) section.
It has the following.
- _segmentGranularity_ - maximum temporal length of segments
- _queryGranularity_ - timestamp precision (stored timestamps will be truncated to this precision)
- _intervals_ - a list of intervals used in the ingestion (records with timestamps outside of these interval will not be ingested)
- _rollup_ - a flag indicating the use of rollup to combine and aggregate similar rows

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Replace the empty _granularitySpec_ with the following.

```
        "granularitySpec": {
          "segmentGranularity": "day",
          "queryGranularity": "hour",
          "intervals": ["2015-09-12/2015-09-13"],
          "rollup": true
        }
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Remember, it's easy to reformat the file. Right-click inside the file, select Command Pallette, then scroll (way) down and select Format Document.</i></p>
<a href="#img-5">
  <img alt="Format the document" src="../assets/FormatDocument.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Format the document" src="../assets/FormatDocument.png" />
</a>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

<a href="#img-6">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<a href="#" class="lightbox" id="img-6">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<h2 style="color:cyan">Easy! Now you understand <i>timestampSpec</i> and <i>granularitySpec</i>!</h2>

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
