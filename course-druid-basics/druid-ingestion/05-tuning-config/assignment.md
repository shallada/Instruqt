---
slug: tuning-config
id: xfnhcpddidy8
type: challenge
title: Tuning Config
teaser: Complete the ingestion spec by specifying the tuning config values
notes:
- type: video
  url: ../assets/05-splash.mp4
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

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the ingestion spec in the editor.

<a href="#img-1">
  <img alt="Open the editor" src="../assets/OpenSpec.png" />
</a>

<a href="#" class="lightbox" id="img-1">
  <img alt="Open the editor" src="../assets/OpenSpec.png" />
</a>

[_tuningConfig_](https://druid.apache.org/docs/latest/ingestion/index.html#tuningconfig)'s have three main values.
- _type_ - matches the ingestion spec type
- _maxRowsInMemory_ - the maximum number of rows that reside in memory before being written
- _maxBytesInMemory_ - the maximum number of bytes that reside in memory before being written
- _partitionSpec_ - contains _maxRowsPerSegment_, which is the maximum number of rows ingested into a single segment

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

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

<a href="#img-3">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<a href="#" class="lightbox" id="img-3">
  <img alt="Save the file" src="../assets/SaveFile.png" />
</a>

<h2 style="color:cyan">That's it! Your ingestion spec is complete!</h2>

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
