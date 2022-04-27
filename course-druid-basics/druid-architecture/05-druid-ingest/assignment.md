---
slug: druid-ingest
id: m8bqtzngoxpx
type: challenge
title: Let's Ingest Data into Druid
teaser: Learn how to ingest Druid data
notes:
- type: video
  url: ../assets/05splash.mp4
tabs:
- title: Console
  type: website
  url: https://query-server-8443-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
- title: Query-shell
  type: terminal
  hostname: query-server
- title: Data-2-shell
  type: terminal
  hostname: data-server-2
- title: Data-1-shell
  type: terminal
  hostname: data-server-1
- title: Master-shell
  type: terminal
  hostname: master-server
- title: Master-editor
  type: code
  hostname: master-server
  path: /root
difficulty: basic
timelimit: 600
---

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>If you have previously completed the Try-it-out track, you will find that the last two steps of this track are identical to those in the Try-it-out track.
This is to demonstrate that the scaled up cluster shown in this track works the same as a single-server installation.
Also, you may not notice a performance improvement using the larger cluster.
This is due to the small amount of data we are using in our educational examples.</i>
<hr style="background-color:cyan">


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Load data by clicking as shown.

<a href="#img-2">
  <img alt="Load data" src="../assets/LoadData.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="Load data" src="../assets/LoadData.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

The console walks you through the ingestion steps.
Since we are using example data, we can just accept the defaults by clickng the _Next:-_ buttons.

<a href="#img-3">
  <img alt="Click next" src="../assets/ClickWildly.png" />
</a>

<a href="#" class="lightbox" id="img-3">
  <img alt="Click next" src="../assets/ClickWildly.png" />
</a>

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>The focuses of this track is Druid deployment.
So, we will not cover the details of ingestion.
But, the purpose of the previous screens through which we wildly clicked was to build an ingestion specification.
You can review the JSON ingestion specification on left side of this final screen.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Finally, click _Submit_ to ingest the data.

<a href="#img-4-1">
  <img alt="Click submit" src="../assets/ClickSubmit.png" />
</a>

<a href="#" class="lightbox" id="img-4-1">
  <img alt="Click submit" src="../assets/ClickSubmit.png" />
</a>

The ingestion takes a minute or so.
You will know Druid has written the segments to deep storage when you see the _SUCCESS_ status.

<a href="#img-4-2">
  <img alt="Wait for SUCCESS" src="../assets/WaitForSuccess.png" />
</a>

<a href="#" class="lightbox" id="img-4-2">
  <img alt="Wait for SUCCESS" src="../assets/WaitForSuccess.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

After Druid writes the segments to deep storage, it then loads the segments for querying.
You can tell the segments are loaded and ready when you see this (you may need to refresh the browser tab a few times).

<a href="#img-5">
  <img alt="Segments Loaded" src="../assets/SegmentsLoaded.png" />
</a>

<a href="#" class="lightbox" id="img-5">
  <img alt="Segments Loaded" src="../assets/SegmentsLoaded.png" />
</a>

<h2 style="color:cyan">Wow! You have ingested the data!</h2>

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
