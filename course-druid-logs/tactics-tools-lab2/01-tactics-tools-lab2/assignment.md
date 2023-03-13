---
slug: tactics-tools-lab2
id: xesix9ehk5xj
type: challenge
title: Tactics and Tools for Reading Druid Log Files - Case Study 2
teaser: Learn to debug another common ingestion problem!
notes:
- type: video
  url: ../assets/05-CaseStudy2.mp4
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
timelimit: 1200
---

Let's diagnose another relatively common ingestion problem.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's run this ingestion.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/local_ingestion.json \
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

Notice that the ingestion failed.


<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Since this is an ingestion problem, let's begin by looking at the middle manager log.


```
less /root/apache-druid-24.0.0/log/middleManager.log
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can search for an error in the log.

```
/ERROR
```

But, we didn't find an error.
As we saw in a previous lab, when we are ingesting with MSQ and the ingestion fails, the ingestion probably failed in a task that the middle manager spun-off.
If this is the case, the task will report _FAILED_.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's search for _FAILED_.

```
/FAILED
```

As we see, this confirms that the task failed, so we need to look at that task log.

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Type _q_ to exit _less_.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's investigate the task's log by grabbing the task ID from the API, and then pulling the log from the API and piping it into _less_.

```
WORKER_TASK_ID=$(curl http://localhost:8081/druid/indexer/v1/tasks 2>/dev/null | jq .[0].id | tr -d '"')
curl http://localhost:8081/druid/indexer/v1/task/$WORKER_TASK_ID/log \
  | less
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

As we learned in a previous lab, we can search for _FAILED_ in the task log.

```
/FAILED
```

We find _FAILED_ near the bottom of the log.
If we use the arrow keys to move up a few lines in the log, we see that the error occurred because of a null timestamp.
So let's go have a look at the data we were trying to ingest.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Type _q_ to exit _less_.

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Since the timestamp is the first field in the records, we can strip the first field and pipe the result into _less_ for inspection.

```
jq .time /root/apache-druid-24.0.0/quickstart/tutorial/wikiticker-2015-09-12-sampled.json | less
```

It may be a bit tedious, but let's look at the timestamps.
We see that the timestamp on the second line looks different from the others (the second line has the format "month-day-year", whereas the others have the format "year-month-day").

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Type _q_ to exit _less_.


<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's fix the format of that timestamp.
We'll use _sed_ because the file is quite large and _sed_ will be able to handle a large file.

```
sed -i 's/12-09-2015T00:47:00.496Z/2015-09-12T00:47:00.496Z/g' /root/apache-druid-24.0.0/quickstart/tutorial/wikiticker-2015-09-12-sampled.json
```

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

Check out the first two lines of the file to see that we changed the timestamp as we intended.

```
head -n 2 /root/apache-druid-24.0.0/quickstart/tutorial/wikiticker-2015-09-12-sampled.json
```

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, let's try the ingestion again.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/local_ingestion.json \
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

We see that this time the ingestion is successful.

<h2 style="color:cyan">Wow, We diagnosed a common ingestion problem!</h2>


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
