---
slug: 05-druid-ingest
id: nckfsnpatf9h
type: challenge
title: Let's Ingest Data into Druid
teaser: Learn how to ingest Druid data
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/21fev9oeqc
tabs:
- title: Console
  type: service
  hostname: query-server
  path: /
  port: 8888
  new_window: true
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


With Druid running, let's look at the Druid console.


<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the green _Open external window_ button in the middle of the adjacent window as shown.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>During this challenge, you will need to switch back and forth between the Console tab and this challenge tab.</i></p>
<hr style="background-color:cyan">

![Click console](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-architecture/ClickConsole.png)

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Load data by clicking as shown.

![Load data](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-architecture/LoadData.png)

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

The console walks you through the ingestion steps.
Since we are using example data, we can just accept the defaults by clickng the _Next:-_ buttons.

![Click next](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-architecture/ClickWildly.png)

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>The focuses of this track is Druid deployment.
So, we will not cover the details of ingestion.
But, the purpose of the previous screens through which we wildly clicked was to build an ingestion specification.
You can review the JSON ingestion specification on left side of this final screen.</i>
<hr style="background-color:cyan">

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Finally, click _Submit_ to ingest the data.

![Click submit](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-architecture/ClickSubmit.png)

The ingestion takes a minute or so.
You will know Druid has written the segments to deep storage when you see the _SUCCESS_ status.

![Wait for SUCCESS](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/WaitForSuccess.png)

<br>
<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

After Druid writes the segments to deep storage, it then loads the segments for querying.
You can tell the segments are loaded and ready when you see this (you may need to refresh the browser tab a few times).

![Segments Loaded](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/SegmentsLoaded.png)
<br>
<h2 style="color:cyan">Wow! You have ingested the data!</h2>