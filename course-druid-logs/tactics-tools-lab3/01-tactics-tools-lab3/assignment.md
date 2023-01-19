---
slug: tactics-tools-lab3
id: qr6whoxqc5cu
type: challenge
title: Tactics and Tools for Reading Druid Log Files - Case Study 3
teaser: Learn to debug yet another common ingestion problem!
notes:
- type: video
  url: ../assets/06-CaseStudy3.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Tail Shell
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

Here's another relatively common ingestion problem.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's run this ingestion.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
/root/mystery.sh
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, let's check the status of the ingestion.


```
curl -m 1  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports
```

We see that the _curl_ command that checks the ingestion status times out!

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's look at the end of the middle manager log to see what might be happening.
Switch to the _Tail Shell_ tab and run this command.

```
tail -f /root/apache-druid-24.0.0/log/middleManager.log
```

We see lots of messages about a ZooKeeper client not being able to connect.
Is ZooKeeper running?

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's look at the running processes.
Back in the _Shell_ tab, run this command.

```
ps -ef
```

We see the Druid processes are running, but where is ZooKeeper?


Notice the defunct Java process.
ZooKeeper is a Java process - I bet ZooKeeper died!

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Here's a command that will get ZooKeeper running again.

```
kill -CONT $(ps -ef | grep 'perl /root' | awk 'NF{print $2}' | head -n 1)
```

<details>
  <summary style="color:cyan"><b>How does this command get ZooKeeper running again?</b></summary>
<hr style="background-color:cyan">
OK, so we played a dirty trick on you!
When we start Druid using the supervisor (as quick-start does), the supervisor will monitor the Druid processes and restart them when they stop.
So, in order to stop ZooKeeper and not have the supervisor restart it, we suspended execution of the supervisor.
<br><br>
The above command resumes execution of the supervisor so it can restart ZooKeeper for us.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Again, check the running processes to see that we successfully started ZooKeeper.
Hint: ZooKeeper is the additional Java process in the list.

```
ps -ef
```

It appears that ZooKeeper is now running.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's retry the ingestion and make sure it now works.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
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

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch back to the _Tail Shell_ tab to review what happened with the middle manager.


It looks like the middle manager successfully reconnected to ZooKeeper.

<h2 style="color:cyan">Hey, We diagnosed another common ingestion problem!</h2>


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
