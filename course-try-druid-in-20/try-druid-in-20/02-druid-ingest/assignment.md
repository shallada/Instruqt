---
slug: druid-ingest
id: mjvk3h7284mi
type: challenge
title: Let's Ingest Data into Druid
teaser: Learn how to ingest Druid data
notes:
- type: video
  url: ../assets/Splash2Video.mp4
tabs:
- title: Console
  type: website
  url: https://container-8443-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
difficulty: basic
timelimit: 600
---

<details>
  <summary style="color:cyan"><b>Want to know about Druid ingestion? Click here!</b></summary>
<hr style="background-color:cyan">
Druid ingestion is about connecting and preparing data for Druid to use.
As you can see in the Druid console Data Loading screen, there are four main steps to ingestion.
These steps include:
<ol>
<li><b>Connect and parse raw data</b> - this is about getting the data into a usable format</li>
<li><b>Transform data and configure schema</b> - this step makes sure you have the right dimensions</li>
<li><b>Tune parameters</b> - this step prepares the rows of data</li>
<li><b>Verify and submit</b> - the final step is for Druid to consume the data</li>
</ol>
<a href="#img-0A">
  <img alt="Four steps of ingestion" src="../assets/FourSections.png" />
</a>
<a href="#" class="lightbox" id="img-0A">
  <img alt="Four steps of ingestion" src="../assets/FourSections.png" />
</a>
Within each of these steps are several activities, which we will explain in other courses.
<br><br>
The whole point of these various steps is to create a specification file that Druid will use to ingest the data.
You can see this specification on the left side of the <i>Submit</i> screen.
<a href="#img-0B">
  <img alt="Building the ingestion spec" src="../assets/BuildSpec.png" />
</a>
<a href="#" class="lightbox" id="img-0B">
  <img alt="Building the ingestion spec" src="../assets/BuildSpec.png" />
</a>
<hr style="background-color:cyan">
</details>


With Druid running, let's look at the Druid console (on the left) and ingest some data.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Load data by clicking as shown.

<a href="#img-2">
  <img alt="Click example data" src="../assets/LoadData.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="Click example data" src="../assets/LoadData.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

The console walks you through the ingestion steps.
Since we are using example data, we can just accept the defaults by clickng the _Next:...->_ buttons.

<a href="#img-3">
  <img alt="Click wildly" src="../assets/ClickWildly.png" />
</a>

<a href="#" class="lightbox" id="img-3">
  <img alt="Click wildly" src="../assets/ClickWildly.png" />
</a>

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>In this introductory track, we will not cover the details of ingestion, but the purpose of the previous screens through which we wildly clicked was to build an ingestion specification.
You can review the JSON ingestion specification on left side of this final screen.
You can learn about ingestion in the Druid Basics course and the Ingestion and Data Modeling course at <a href="https://learn.imply.io/" target="_blank">learn.imply.io</a>.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Finally, click _Submit_ to ingest the data.

<a href="#img-4">
  <img alt="Click Next" src="../assets/ClickSubmit.png" />
</a>

<a href="#" class="lightbox" id="img-4">
  <img alt="Click Next" src="../assets/ClickSubmit.png" />
</a>

The ingestion takes a minute or so.
You will know Druid has written the segments to deep storage when you see the _SUCCESS_ status (you may have to scroll the window to the right).

<a href="#img-5">
  <img alt="Wait for SUCCESS" src="../assets/WaitForSuccess.png" />
</a>

<a href="#" class="lightbox" id="img-5">
  <img alt="Wait for SUCCESS" src="../assets/WaitForSuccess.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

After Druid writes the segments to deep storage, it then loads the segments for querying.
You can tell the segments are loaded and ready when you see this (you may need to refresh the browser tab a few times).

<a href="#img-6">
  <img alt="Segments Loaded" src="../assets/SegmentsLoaded.png" />
</a>

<a href="#" class="lightbox" id="img-6">
  <img alt="Segments Loaded" src="../assets/SegmentsLoaded.png" />
</a>

<h2 style="color:cyan">Cool! You have ingested the data!</h2>


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
