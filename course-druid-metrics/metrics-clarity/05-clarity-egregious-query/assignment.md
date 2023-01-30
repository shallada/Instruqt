---
slug: clarity-egregious-query
id: bfyo6pxlhzos
type: challenge
title: Identify a Problematic Query
teaser: Let's Clarity's metrics to identify an egregious query
notes:
- type: video
  url: ../assets/09-MysteryQuery.mp4
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


In this exercise, we'll use the query metrics to identify a problematic query.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

In Clarity, set up a view of the max query time for the _clickstream-data_ table datasource.

Start by selecting _Broker Queries_ from the hamburger menu.

<a href="#img-1">
  <img alt="Broker Queries" src="../assets/BrokerQueries.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Broker Queries" src="../assets/BrokerQueries.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Make sure the filter is set to _Latest hour_ and _Auto update_ is every minute.

<a href="#img-2">
  <img alt="Every Hour Latest Minute" src="../assets/EveryHourLatestMinute.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Every Hour Latest Minute" src="../assets/EveryHourLatestMinute.png" />
</a>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Set up the view by showing _Time (Minute)_, selecting the _Max Query Time_ query and selecting the _clickstream-data_ table datasource.

<a href="#img-3">
  <img alt="Max Query Time" src="../assets/MaxQueryTime.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Max Query Time" src="../assets/MaxQueryTime.png" />
</a>

Recall that we started a query workload in the previous exercise.
The metrics we are looking at here are the maximum query times for each minute referencing the query workload.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's perform a mysterious query.


Back in the shell, execute this query command.

```
curl -X 'POST' -H 'Content-Type:application/json' -d @/root/mystery_query.json http://localhost:8888/druid/v2/sql > /dev/null
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Click the _Clarity_ tab and look at the chart for the maximum query times again.
You will see a spike as a result of the query.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>After executing the mysterious query, you will need to wait (up to a minute) for the metrics to refresh before you will see the spike.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's pretend we don't know what caused the spike and investigate the egregious query.


In preparation for a later step, back in the shell, copy and paste the following command, BUT DO NOT EXECUTE IT YET!

```
QUERY_ID=$(echo '<PASTE CLIPBOARD HERE>' | jq '."SQL Query ID"')
```


<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Clarity_ tab, replace _Time_ with _SQL Query ID_ in the _SHOW_ list for the chart.

<a href="#img-7">
  <img alt="Replace Time" src="../assets/ReplaceTime.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Replace Time" src="../assets/ReplaceTime.png" />
</a>

Here we see a sorted list of maximum query times.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's copy the maximum query at the top from the list.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Be sure to select the top query and NOT the "Overall" line at the very top.</i>
<hr style="background-color:cyan">

<a href="#img-8">
  <img alt="Copy Egregious" src="../assets/CopyEgregious.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Copy Egregious" src="../assets/CopyEgregious.png" />
</a>


<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Shell_, replace <i>&lt;PASTE CLIPBOARD HERE&gt;</i> with the contents of the clipboard from the previous step.

After the replacement, the command will look similar to the following (the pasted section is shown in light blue):

<p><span style="color:cyan"><i>QUERY_ID=$(echo '<span style="color:lightblue">{ "SQL Query ID": "9af62124-779e-4c67-8191-5dd84fbe4d0b", "Max Query Time": "1341" }</span>' | jq '."SQL Query ID"')</i></span>

Execute the command.


This command isolates the query ID and stores it in a variable named <i>QUERY_ID</i>.
You can review the contents of the variable with the following command.

```
echo $QUERY_ID
```

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

We enabled query logging when we started Druid, so we can search the log files for the query ID.
Read more about enabling query logging <a href="https://support.imply.io/hc/en-us/articles/360011745614-Enable-Query-or-Request-logging-for-Druid" target="_blank">here</a>.


Use the following command to search the log files.

```
grep $QUERY_ID /root/imply-2022.11/var/sv/broker/current | grep -P '"SELECT.*?",'
```

We can see the logged query within the log message.
Note that this query performs a _SELECT *_ with no _WHERE_ clause, which requires Druid to do a full table scan - a very slow query.

It's no wonder that the query was so slow!

<h2 style="color:cyan">Wow! We see how Clarity and metrics can help us understand Druid performance issues!</h2>


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
