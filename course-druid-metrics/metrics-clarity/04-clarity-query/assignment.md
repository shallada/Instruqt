---
slug: clarity-query
id: pwkma3slnsdj
type: challenge
title: Create a Clarity Query Load
teaser: Let's simulate a query load and views its metrics in Clarity
notes:
- type: video
  url: ../assets/08-ClarityQueries.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
- title: Pivot
  type: website
  url: https://container-9095-${_SANDBOX_ID}.env.play.instruqt.com/pivot/home
- title: Clarity
  type: website
  url: https://container-9095-${_SANDBOX_ID}.env.play.instruqt.com/clarity
difficulty: basic
timelimit: 600
---


In this exercise, we'll use the Druid query generator, which is in the same repo as the Druid data generator that we used in the previous exercise.
Read about this query generator <a href="https://github.com/implydata/druid-datagenerator/blob/main/druid-querygenerator/README.md" target="_blank">here</a>.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

This query generator has an example query configuration file that works with the clickstream data we are already ingesting.
You can check out this configuration file <a href="https://github.com/implydata/druid-datagenerator/blob/main/druid-querygenerator/examples/clickstream_query.json" target="_blank">here</a>.


Let's start the query generator in the background.

```
nohup python3 /root/druid-datagenerator/druid-querygenerator/DruidQueryDriver.py -f /root/druid-datagenerator/druid-querygenerator/examples/clickstream_query.json 2> /dev/null > /dev/null & disown
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's review some of the Clarity query metrics.
Click on the Clarity tab.


On the left section of the Clarity display, there is a list of various metrics views subdivided into subsections of _QUERIES_, _INGESTION_, _SERVER_, and _EXCEPTIONS_.

Click on, and review, each of the views in the _QUERY_ section on the left.

<a href="#img-2">
  <img alt="Query Overview" src="../assets/QueryOverview.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Query Overview" src="../assets/QueryOverview.png" />
</a>

These are helpful preconfigured views. We can customize these views, or create views of our own from scratch.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can create our own custom view.
Click on the hamburger menu in the top-left corner, then select _Broker Queries_.

<a href="#img-3">
  <img alt="Broker Queries" src="../assets/BrokerQueries.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Broker Queries" src="../assets/BrokerQueries.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's set the time filter and change the refresh rate.

<a href="#img-4">
  <img alt="Setup Query Time" src="../assets/SetupQueryTime.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Setup Query Time" src="../assets/SetupQueryTime.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can view the metrics as time-charts.
Show the time dimension and limit the charts to the _clickstrea-data_ table datasource.

<a href="#img-5">
  <img alt="Add Query Time" src="../assets/AddQueryTime.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Add Query Time" src="../assets/AddQueryTime.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's look at several metrics within the same view.

<a href="#img-6">
  <img alt="Add Query Charts" src="../assets/AddQueryCharts.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Add Query Charts" src="../assets/AddQueryCharts.png" />
</a>


<h2 style="color:cyan">This is really cool! We can learn lots about our queries in Clarity!</h2>


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
