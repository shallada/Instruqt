---
slug: 05-tuning-config
id: xfnhcpddidy8
type: challenge
title: Tuning Config
teaser: Complete the ingestion spec by specifying the tuning config values
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/i0ztfux2p3
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
The final piece we need to put in place is the [_tuningConfig_](https://druid.apache.org/docs/latest/ingestion/index.html#tuningconfig) section.
This section gives the ingestion process some parameters for segment creation.

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the ingestion spec in the editor.

![Open the editor](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-ingestion/OpenSpec.png)

[_tuningConfig_](https://druid.apache.org/docs/latest/ingestion/index.html#tuningconfig)'s have three main values.
- _type_ - matches the ingestion spec type
- _maxRowsInMemory_ - the maximum number of rows that reside in memory before being written
- _maxBytesInMemory_ - the maximum number of bytes that reside in memory before being written
- _partitionSpec_ - contains _maxRowsPerSegment_, which is the maximum number of rows ingested into a single segment

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Replace the empty _tuningConfig_ section (near the bottom of the file) with the following.

```
    "tuningConfig" : {
      "type" : "index_parallel",
      "maxRowsInMemory" : 25000,
      "maxBytesInMemory" : 250000,
      "partitionSpec" : {
        "type" : "dynamic",
        "maxRowsPerSegment" : 5000000
      }
    }
```

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

![Save the file](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-ingestion/SaveFile.png)

<br>
<h2 style="color:cyan">That's it! Your ingestion spec is complete!</h2>