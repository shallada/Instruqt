---
slug: log-retention
id: b7eq0lwtpwki
type: challenge
title: Druid Log Retention
teaser: Log files take up space. Eventually we need to purge them. Learn how to configure
  automatic Druid log retention.
notes:
- type: video
  url: ../assets/08-DruidLogRetention.mp4
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

In this lab, we'll look at how to configure retention of both the process logs, and the task logs.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We have configured the lab with a clean Druid installation, except we have modified the configuration to store task logs in MinIO.


Druid is not running yet.
Verify that the log directory does not yet exist.

```
tree -L 1 /root/apache-druid-24.0.0
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Open the _log4j2.xml_ configuration file as shown.

<a href="#img-2">
  <img alt="Open log4J2 config" src="../assets/Openlog4J2Config.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Open log4J2 Config" src="../assets/Openlog4J2Config.png" />
</a>


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the _RollingRandomAccessFile_ appender, modify the _filePattern_ to be as follows.

```
filePattern="${sys:druid.log.path}/${sys:druid.node.type}.%d{yyyyMMdd-HH:mm}-%i.log"
```

<details>
  <summary style="color:cyan"><b>What does this do?</b></summary>
<hr style="background-color:cyan">
<i>filePattern</i> specifies how Log4J2 will name the rolled log files.
Read more <a href="https://logging.apache.org/log4j/2.x/manual/appenders.html" target="_blank">here</a>.
<ul>
  <li><b>${sys:druid.log.path}</b> becomes the path to the log file</li>
  <li><b>${sys:druid.node.type}</b> becomes the Druid process name</li>
  <li><b>%d{yyyyMMdd-HH:mm}</b> becomes the date (i.e., year, month, day, hour and minute)</li>
  <li><b>%i</b> becomes the file version number within the minute</li>
</ul>
<hr style="background-color:cyan">
</details>


<a href="#img-3">
  <img alt="Modify File Pattern" src="../assets/ModifyFilePattern.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Modify File Pattern" src="../assets/ModifyFilePattern.png" />
</a>


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">


Add a size-based rule to the triggering policies.
Read more about triggering policies <a href="https://logging.apache.org/log4j/2.x/manual/appenders.html#TriggeringPolicies" target="_blank">here</a>.


```
<SizeBasedTriggeringPolicy size="5 KB" />
```

<a href="#img-4">
  <img alt="Add Size Based Trigger" src="../assets/AddSizeBasedTrigger.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Add Size Based Trigger" src="../assets/AddSizeBasedTrigger.png" />
</a>

<details>
  <summary style="color:cyan"><b>How does the size-based trigger work?</b></summary>
<hr style="background-color:cyan">
This trigger tells Log4J2 to create a new file when the most recent logged message exceeds 5KB.
You will notice that the log files will be slightly larger than 5KB, except for the most recent log file within the time interval.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Change _IfLastModified_ to two minutes.

<details>
  <summary style="color:cyan"><b>Why are we changing this?</b></summary>
<hr style="background-color:cyan">
Normally, we wouldn't set this value to two minutes because that would cause Druid to create too many log files.
In this lab we set the value to two minutes for illustration purposes so we can see results quickly.
<hr style="background-color:cyan">
</details>


```
<IfLastModified age="T2M" />
```

<a href="#img-5">
  <img alt="Change If Last Modified" src="../assets/ChangeIfLastModified.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Change If Last Modified" src="../assets/ChangeIfLastModified.png" />
</a>

<details>
  <summary style="color:cyan"><b>What does <i>IfLastModified</i> do?</b></summary>
<hr style="background-color:cyan">
This rule tells Log4J2 when to delete log file.
In this case we have set the value to two minutes (<i>T2M</i>).
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the Log4J2 configuration file.

<a href="#img-6">
  <img alt="Save Log4j2 Config" src="../assets/SaveLog4j2Config.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Save Log4j2 Config" src="../assets/SaveLog4j2Config.png" />
</a>


<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Up to this point, we have been focused on Druid process logs.
Now, we will shift our attention to the task logs.
Let's set the retention policy for the task logs.
Read more <a href="https://druid.apache.org/docs/latest/configuration/index.html#log-retention-policy" target="_blank">here</a>.


Open the Overlord's runtime configuration file.

<a href="#img-7">
  <img alt="Open Overlord Config" src="../assets/OpenOverlordConfig.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Open Overlord Config" src="../assets/OpenOverlordConfig.png" />
</a>


<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Put these at the bottom of the Overlord runtime config file.

```
druid.indexer.logs.kill.enabled=true
druid.indexer.logs.kill.durationToRetain=120000
druid.indexer.logs.kill.initialDelay=60000
druid.indexer.logs.kill.delay=60000
```

<a href="#img-8">
  <img alt="Add Overlord Config" src="../assets/AddOverlordConfig.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Add Overlord Config" src="../assets/AddOverlordConfig.png" />
</a>

<details>
  <summary style="color:cyan"><b>What do these settings do?</b></summary>
<hr style="background-color:cyan">
Setting <i>druid.indexer.logs.kill.enabled</i> to true tells Druid to delete old task log files.
Setting <i>druid.indexer.logs.kill.durationToRetain</i> tells Druid how old (in milliseconds) log files must be to be deleted.
Setting <i>druid.indexer.logs.kill.initialDelay</i> tells Druid how long to wait (in milliseconds) before attempting to delete old log files.
Setting <i>druid.indexer.logs.kill.delay</i> tells Druid how long to wait (in milliseconds) after between attempting to delete old log files for the first time since the process started".
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the Overlord configuration file.

<a href="#img-8">
  <img alt="Save Overlord Config" src="../assets/SaveOverlordConfig.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Save Overlord Config" src="../assets/SaveOverlordConfig.png" />
</a>

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Shell_ tab, start Druid.

```
nohup /root/apache-druid-24.0.0/bin/start-nano-quickstart \
  > /root/log.out 2> /root/log.err \
  < /dev/null & disown
```

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Monitor the Coordinator-Overlord logs to see Druid create different versions of the log files.
Run the following commands several times during a couple of minutes to see what happens.

```
ls -al /root/apache-druid-24.0.0/log/coordinator-overlord.*
```

<details>
  <summary style="color:cyan"><b>What are we seeing?</b></summary>
<hr style="background-color:cyan">
We see that Log4J2 creates many different log files.
We can see that Log4J2 creates new files either when writing to the file and the size exceeds 5KB, or when writing to a file and the time (to the minute) varies from the other entries in the file (as noted in the file name).
We also notice that Log4J2 only keeps the most recent two minutes of log files.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

When you have a feel for how Log4J2 creates the log files, wait for Druid to complete initialization.

```
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]
do
  echo "Waiting for Druid to initialize..."
  sleep 3
done
```

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, start an ingestion so we can observe the task log files.

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


<h2 style="color:cyan">Step 14</h2><hr style="color:cyan;background-color:cyan;height:5px">

Monitor the task logs and their creation times.
Run the following command periodically for a minute or two.

```
curl http://localhost:8081/druid/indexer/v1/tasks 2>/dev/null | jq '.[] | .id, .createdTime'

```

Eventually, we see the task logs disappear.

<h2 style="color:cyan">There you go! We see how to configure Druid log retention!</h2>


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
