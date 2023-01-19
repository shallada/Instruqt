---
slug: tactics-tools-lab1
id: 6jnhzogycbrw
type: challenge
title: Apache Druid® Tactics and Tools Case Study 1
teaser: Use logs to diagnose a Druid problem
notes:
- type: video
  url: ../assets/04-CaseStudy1.mp4
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

In this lab, we'll ingest some data using MSQ's _join_ capability.
But, this ingestion may encounter a problem!


How do we determine the cause of the problem?


<details>
  <summary style="color:cyan"><b>Want to know more about the ingestion?</b></summary>
<hr style="background-color:cyan">
Here we again ingest the sample wikipedia data, but with a twist.
We want to associate languages with each wikipedia record.
So, we will join a languages table (found in /root/langs.json) with the wikipedia data.
<hr style="background-color:cyan">
</details>



<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let’s use the following commands to ingest the sample wikipedia data and join it to the languages table.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/big_ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
sleep 3
while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
  | jq .multiStageQuery.payload.status.status 2> /dev/null \
  | grep 'SUCCESS\|FAILED' | wc -w) -eq 0 ]; \
  do
    echo "Waiting for ingestion to complete..."
     sleep 3
  done
echo "Ingestion completing"
sleep 5
curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports \
  | jq .multiStageQuery.payload.status.status
```

We see from this command that the ingestion failed!
What should we do to determine the cause of the failure?

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Since we know that ingestion starts with the middle manager process, let's peruse the middle manager's log file.

```
less /root/apache-druid-24.0.0/log/middleManager.log
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Search the log for an error message.
We can work with _less_ interactively to do the search.
Copy and paste the following command into _less_.

```
/ERROR
```

Strange! We don't see an error.


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's search again for fail.
Copy and paste the following command into _less_.

```
/FAIL
```

If we look carefully at the line  containing _FAILED_ and the context around it, we see that the middle manager launched a task which resulted in failure.


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Type _q_ to exit the _less_ command.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Recall that we retrieve task logs using the API.
We could grab the task ID from the middle manager's log file, or we can use the API.
The following commands:
1. Grab the ID using the API
2. Retrieve the task log using the API
3. Pipe the log file contents into _less_

```
WORKER_TASK_ID=$(curl http://localhost:8081/druid/indexer/v1/tasks 2>/dev/null | jq .[0].id | tr -d '"')
curl http://localhost:8081/druid/indexer/v1/task/$WORKER_TASK_ID/log \
  | less
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Within _less_, let's search for the error.

```
/ERROR
```

If we investigate the lines around the _ERROR_, we see it has to do with the broadcast join - something about the broadcast table being too large.
We see the message “memory reserved for broadcast tables = 28296288 bytes” in the log

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Remember, when using less, scroll up a page with the b key.
Scroll down a page using the space bar, and scroll up/down one line using the arrow keys.</i></p>
<hr style="background-color:cyan">


<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">


Type _q_ to exit the _less_ command.

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's look at the size of the join table.

```
wc /root/langs.json
```

We can see that the table is very large (over 65 MB), consisting of over a million lines.
Since Druid currently only does broadcast joins, the joining table needs to be small enough to fit into memory.

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

If we were to look at the first 50 lines of the file, we would see valid language mappings.
But after the first 50 lines, the file contains bogus data.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>langs.json is very large, so you may just want to take our word for it that only the first 50 lines are valid.
However if you don't want to trust us, you can inspect the file with <code>less /root/langs.json</code> - you may not want to use the editor as the file is so large that it takes a while to load.</i></p>
<hr style="background-color:cyan">


Let's truncate the file after the first 50 lines.

```
head -n 50 /root/langs.json > langs.tmp
mv -f /root/langs.tmp /root/langs.json
```

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, let's rerun the ingestion to see that it succeeds.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/big_ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
sleep 3
while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
  | jq .multiStageQuery.payload.status.status 2> /dev/null \
  | grep 'SUCCESS\|FAILED' | wc -w) -eq 0 ]; \
  do
    echo "Waiting for ingestion to complete..."
     sleep 3
  done
echo "Ingestion completing"
sleep 5
curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports \
  | jq .multiStageQuery.payload.status.status
```


<h2 style="color:cyan">Congratulations on debugging this ingestion problem!</h2>


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
