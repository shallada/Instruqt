---
slug: druid-process-flow
id: cvmi4szmux9m
type: challenge
title: Understand Druid's Process Work Flow with Logs
teaser: Learn which logs to investigate for various Druid operations
notes:
- type: video
  url: ../assets/03-DruidProcessFlowWithLogs.mp4
tabs:
- title: Tail Shell
  type: terminal
  hostname: container
- title: Ingestion Shell
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

In this lab we want to use the logs to get a feel for the interplay of Druid processes.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start up _multitail_ on three different (coordinator, middle manager and historical) log files.

<details>
  <summary style="color:cyan"><b>What is <i>multitail</i>?</b></summary>
<hr style="background-color:cyan">
You may be familiar with the Linux <i>tail</i> command, which allows you to see that last few lines of a file.
People often use <i>tail</i> with the </i>-f</i> option so that <i>tail</i> will continue to output lines of the file as the file is appended to.
<br><br>
<i>multitail</i> is like <i>tail</i>, except we can watch the last few lines of several files at the same time.
The <i>-p l</i> option turns-off line wrap and left-justifies the lines.
Since in this exercise, we will not be looking at the logs in detail, we use this option to make it a little easier to follow the log interaction.
Read more about <i>multitail</i> <a href="https://linux.die.net/man/1/multitail" target="_blank">here</a>.
Also, when <i>multitail</i> is running, you can type <i>h</i> to see a list of interactive commands you can use.
<hr style="background-color:cyan">
</details>


```
multitail \
  -p l -f /root/apache-druid-24.0.0/log/coordinator-overlord.log \
  -p l -f /root/apache-druid-24.0.0/log/middleManager.log \
  -p l -f /root/apache-druid-24.0.0/log/historical.log
```

Now that we can see the logs, we'll start an ingestion in the _Ingestion Shell_ tab, and watch what happens to the logs.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Type _Op &lt;return&gt;_ in _multitail_ to insert a red line marker in the log output.
This will help us see where Druid appends lines to the log files.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch to the _Ingestion Shell_ tab.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Start the ingestion with the following command.

<hr style="background-color:orange">
<p><span style="color:orange"><strong><em>IMPORTANT:</em></strong></span><i>This command will delay for 10 seconds before beginning the ingestion.
During this time, we need to switch back to the Tail Shell tab so we can view the logs!</i></p>
<hr style="background-color:orange">


```
sleep 10
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
sleep 3
while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
  | jq .multiStageQuery.payload.status.status 2> /dev/null \
  | grep SUCCESS | wc -w) -eq 0 ]; \
  do
    echo "Waiting for ingestion to complete..."
     sleep 3
  done
echo "Ingestion completing"
sleep 5
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch back to the _Tail Shell_ tab.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

You will notice:
1. Activity in the overlord log (top) first as the overlord begins the ingestion
2. Activity in the middle manager log (middle) as it starts the ingestion task
3. Eventually, activity in the historical log (bottom) as the historicals pull the resulting ingestion segment

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>We will not see the task logs for the ingestion.
Recall that each task creates a separate log, and that we use the API to retrieve the log.
However, we will see (near the bottom of the middle manager log) the local location of the task log file.
We can use the editor (or the <i>less</i> command) to peruse the task log file locally.</i></p>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, let's look at the logs while performing a query (we have enabled query logging).


In the _Tail Shell_ tab, click anywhere in the _multitail_ output and type _q_ to quit.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, let's launch _multitail_ on the two query log files (broker and historical) and type _Op &lt;return&gt;_ to place a marker in the output.

```
multitail \
  -p l -f /root/apache-druid-24.0.0/log/broker.log \
  -p l -f /root/apache-druid-24.0.0/log/historical.log
```

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Ingestion Shell_ tab, launch this query before immediately switching back to the _Tail Shell_ tab.

```
sleep 10
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | jq
```

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch back to the _Tail Shell_ tab and wait for the query log output to update.


We see that both the broker and historical processes get involved in the query.

<h2 style="color:cyan">Remarkable! We see evidence of the Druid process interplay in the log files!</h2>


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
