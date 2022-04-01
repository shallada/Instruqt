---
slug: 02-druid-ingest
id: eklkv79ly4ah
type: challenge
title: Let's Ingest Data into Druid
teaser: Learn how to ingest Druid data
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/f3zmu81swx
tabs:
- title: Console
  type: service
  hostname: container
  path: /
  port: 8888
  new_window: true
- title: Shell
  type: terminal
  hostname: container
difficulty: basic
timelimit: 700
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
<img src="https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/FourSections.png" alt="Four steps of ingestion">
Within each of these steps are several activities, which we will explain in later tracks on ingestion.
<br><br>
The whole point of these various steps is to create a specification file that Druid will use to ingest the data.
You can see this specification on the left side of the <i>Submit</i> screen.
<img src="https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/BuildSpec.png" alt="Building the ingestion spec">
<hr style="background-color:cyan">
</details>


With Druid running, let's look at the Druid console.

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the green _Open external window_ button in the middle of the adjacent window as shown.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>During this challenge, you will need to switch back and forth between the Console tab and this challenge tab.</i></p>
<hr style="background-color:cyan">

![Click console](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/ClickConsole.png)

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Load data by clicking as shown.

![Click example data](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/LoadData.png)

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

The console walks you through the ingestion steps.
Since we are using example data, we can just accept the defaults by clickng the _Next:-_ buttons.

![Click example data](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/ClickWildly.png)

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>In this introductory track, we will not cover the details of ingestion, but the purpose of the previous screens through which we wildly clicked was to build an ingestion specification.
You can review the JSON ingestion specification on left side of this final screen.
Note that we explain the ingestion spec and the purpose of these screens in the Ingestion track.</i>
<hr style="background-color:cyan">

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Finally, click _Submit_ to ingest the data.

![Click Next](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/ClickSubmit.png)

The ingestion takes a minute or so.
You will know Druid has written the segments to deep storage when you see the _SUCCESS_ status.

![Wait for SUCCESS](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/WaitForSuccess.png)

<br>
<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

After Druid writes the segments to deep storage, it then loads the segments for querying.
You can tell the segments are loaded and ready when you see this (you may need to refresh the browser tab a few times).

![Segments Loaded](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/SegmentsLoaded.png)

<h2 style="color:cyan">Cool! You have ingested the data!</h2>