---
slug: ingest-nested-data
id: uk97au8a9rlm
type: challenge
title: Ingest Nested Data
teaser: Let's ingest the nested data
notes:
- type: text
  contents: Please be patient while we prepare the lab
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
- title: Druid Console
  type: website
  url: https://container-8443-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
difficulty: basic
timelimit: 600
---

In the previous exercise, we created some example nested data.
In this exercise we will ingest that example data.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's ingest the nested data into a table datasource named <i>nested_data</i>.
We'll use _Connect external data_ tool within the _Query_ tab of the _Druid Console_ as shown.

<a href="#img-1">
  <img alt="Connect External Data" src="../assets/ConnectExternalData.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Connect External Data" src="../assets/ConnectExternalData.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Select the _Local disk_ option.
Set the _Base directory_ to _/root_ and the _File filter_ to <i>nested_data.json</i>.

<a href="#img-2">
  <img alt="Select Local Disk" src="../assets/SelectLocalDisk.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Select Local Disk" src="../assets/SelectLocalDisk.png" />
</a>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Inspect the results from parsing the external data, and click _Done_.

<a href="#img-3">
  <img alt="Accept External Data" src="../assets/AcceptExternalData.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Accept External Data" src="../assets/AcceptExternalData.png" />
</a>

Once you click _Done_, you will see the SQL query we can use to ingest the data.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Investigate the query and how it handles the nested data.
We see the ingestion uses the _COMPLEX_ type - Read more <a href="https://druid.apache.org/docs/latest/querying/nested-columns.html#ingest-a-json-string-as-complexjson" target="_blank">here</a>.
Run the ingestion as shown.

<details>
  <summary style="color:cyan"><b>Why does the query use <i>REPLACE</i> instead of <i>INSERT</i>?</b></summary>
<hr style="background-color:cyan">
The <i>REPLACE</i> operation replaces the data instead of inserting.
Read more <a href="https://druid.apache.org/docs/latest/multi-stage-query/reference.html#replace" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


When the ingestion is complete, run the query as shown.

<a href="#img-4">
  <img alt="Run Ingestion" src="../assets/RunIngestion.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Run Ingestion" src="../assets/RunIngestion.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Inspect how Druid stores the nested data.

<a href="#img-5">
  <img alt="Inspect Nested Data" src="../assets/InspectNestedData.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Inspect Nested Data" src="../assets/InspectNestedData.png" />
</a>

We see that the nested data is stored as a JSON string.


<h2 style="color:cyan">Cool! Now we have a table datasource with nested data!</h2>


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
