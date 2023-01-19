---
slug: log-basics
id: 4ynfoqxzryku
type: challenge
title: A Tour of Druid's Log Files
teaser: Learn what logs are available and where to find them
notes:
- type: video
  url: ../assets/01-ATourOfDruidsLogFiles.mp4
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
- title: Tail Shell
  type: terminal
  hostname: container
difficulty: basic
timelimit: 900
---

<h2 style="color:cyan">Let's become familiar with the various log files.</h2>

In this lab, we'll learn about the log files that Druid creates.
We'll learn how to read these log files in subsequent labs.

<details>
  <summary style="color:cyan"><b>I want the back story on log files and this lab.</b></summary>
<hr style="background-color:cyan">
As Druid processes run, they write status information into files called <i>log files</i>.
We can use these files to understand the Druid processes' behaviors and diagnose problems.
<br><br>
Since Druid is a distributed system, we will find log files for each druid process.
In addition, Druid also captures the output written to the standard output.
<br><br>
Some processes may spin off <i>tasks</i> to perform sub-processing.
In Druid, a task is separate process that usually runs in its own JVM.
Each of these tasks create their own log files.
<Br><br>
Many of the logs capture behavior during ingestion and other processing, but we can also configure Druid to capture specific query information.
<br><br>
We'll see examples of each of these log files in this lab.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We have installed and launched a single server version of Druid.
We can check out the list of running processes with the following command.

```
ps -ef | grep "Main server [A-Za-z]*$" | awk 'NF{print $NF}'
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

In this example, we launched Druid (during the lab setup) using one of the single server scripts.
We have redirected the output from the script to a file named _log.out_.


Review the contents of _log.out_ using the following command.

```
cat /root/log.out
```

We see that the launching script outputs the location of the log files.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>The output suggests a URL for the Druid Console on localhost.
Because this training environment is slightly different, we have provided a separate tab named "Druid Console", which gives us access to the console.</i></p>
<hr style="background-color:cyan">


<details>
  <summary style="color:cyan"><b>My production system doesn't use a simple launch script. Where do I find my log files?</b></summary>
<hr style="background-color:cyan">
In production we won't launch our Druid cluster using a simple script, so our log files will be in different locations.
<br><br>
We can set the location of our log files using Druid's configuration files.
We'll see how to do this in later labs.
For now, let's just become familiar with the different types of Druid log files.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Using the information from the launch script output, we can see the various process logs using the following command.

```
tree /root/apache-druid-24.0.0/log
```

Note that we see two files for each Druid process (including zookeeper):
- &lt;process name&gt;.stdout.log file - which is the information written by the processes to _stdout_ (i.e., the terminal)
- &lt;process name&gt;.log - file containing various status, error, warning and debug messages

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by looking at the _stdout_ file for the broker process.

```
cat /root/apache-druid-24.0.0/log/broker.stdout.log
```

This file contains a line indicating the location of the other log file.

<details>
  <summary style="color:cyan"><b>What's the <i>..</i> in the log file path?</b></summary>
<hr style="background-color:cyan">
The two dots are an alias meaning the parent directory.
Therefore, the two dots effectively "cancel out" the previously specified directory.
<br><br>
So, instead of:
<br>
<code>/root/apache-druid-24.0.0/bin/../log/broker.log</code>
<br>
a more concise path for the log file is:
<br>
<code>/root/apache-druid-24.0.0/log/broker.log</code>
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's investigate the Broker log using the editor.

<a href="#img-5">
  <img alt="Edit Broker Log" src="../assets/EditBrokerLog.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Edit Broker Log" src="../assets/EditBrokerLog.png" />
</a>

Each line in the file is a separate status message that has a timestamp, information indicating its severity, its origin, and a note about what happened.
We'll explain the format of these messages in a later lab.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

This lab has a second command shell in the tab named _Tail Shell_.
Switch to the _Tail Shell_ tab, and let's look at the end of the Middle Manager log using the following command.

<details>
  <summary style="color:cyan"><b>What does this command do?</b></summary>
<hr style="background-color:cyan">
The <i>tail</i> command shows the last few lines of a file.
The <i>-f</i> option causes the command to continue to listen and output additional lines of the file as the file grows.
<hr style="background-color:cyan">
</details>

```
tail -f /root/apache-druid-24.0.0/log/middleManager.log
```

Leave the _tail_ command running in this tab.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's ingest some data to see the effects in the logs.
Switch back to the _Shell_ tab and launch an ingestion using the following command.


<details>
  <summary style="color:cyan"><b>What does this command do?</b></summary>
<hr style="background-color:cyan">
Admittedly, this command is a bit gnarly.
But to summarize, the command uses a Druid API to launch an ingestion.
The output from the API command contains the ingestion task ID.
So, we parse out the task ID and save it in a variable for later use.
The command also duplicates the output to the shell so we can see it.
<hr style="background-color:cyan">
</details>

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>We are using the MSQ asynchronous API.
So, the previous command merely starts the ingestion process.
We will use a second API to determine when Druid has completed the ingestion.</i></p>
<hr style="background-color:cyan">

Feel free to switch back and forth between the _Shell_ tab and the _Tail Shell_ tab to watch the log as the ingestion proceeds.
The _Task [query-xxxxx] started_ message indicates the Middle Manager has spun off a worker task to perform the ingestion.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Run the following command in the _Shell_ tab.
This command waits for Druid to complete the ingestion.

```
while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
  | jq .multiStageQuery.payload.status.status \
  | grep SUCCESS | wc -w) -eq 0 ]; \
  do
    echo "Waiting for ingestion to complete..."
     sleep 3
  done
echo "Ingestion completing"
sleep 5
```

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, switch back to the _Tail Shell_ tab and look the Middle Manager log again.


We notice that the log shows additional messages resulting from the ingestion.
For example, notice the _Task [query-xxxx] completed with status [SUCCESS]_ message indicating that the separate task has completed.
Also, you can _echo $TASK_ID_  (run this command in the _Shell_ tab) to see that the task ID returned by the API (in Step 7) is the same ID as that shown in the related messages.

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

In addition to long-running processes, Druid also uses shorter running processes called tasks to perform ingestion.
Back in the _Shell_ tab, we can retrieve a list of the task IDs of the processes Druid used in the previous ingestion.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Tasks allow Druid to momentarily parallelize processing when necessary.
The task processes for the previous ingestion have completed and are no longer running, but they left log files which we will investigate.</i></p>
<hr style="background-color:cyan">

```
curl http://localhost:8081/druid/indexer/v1/tasks 2>/dev/null | jq .[].id
```

We see two tasks in the list:
- A controller task - manages the ingestion
- A worker task - performs a part of the ingestion

More complex ingestions may require additional worker tasks, which run in parallel to improve ingestion performance.

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can use the API to view the log for this task.
Let's use the following command to grab the ID of the worker task, and store it in a variable (run this command in the _Shell_ tab).

```
WORKER_TASK_ID=$(curl http://localhost:8081/druid/indexer/v1/tasks 2>/dev/null | jq .[0].id | tr -d '"')
```

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's retrieve the task's log (run this command in the _Shell_ tab).

<details>
  <summary style="color:cyan"><b>Why do we use <i>curl</i> to get the log file?</b></summary>
<hr style="background-color:cyan">
We may be wondering why we don't just look at the task's log file in the editor - why are we using <i>curl</i> instead?
<br><br>
Druid can generate a lot of task log files.
Tasks write the log files to local storage, which could cause Druid to run out of local storage quickly.
Therefore, Druid migrates the task logs to longer-term storage.
<br><br>
Since task log files are migratory (similar to Monty Python's coconuts), task logs may be difficult to locate.
Therefore, Druid provides an API that makes retrieving the task log files easy.
All we need is the task ID, which we acquired in the previous step.
<hr style="background-color:cyan">
</details>


```
curl http://localhost:8081/druid/indexer/v1/task/$WORKER_TASK_ID/log
```

Of course, we could also redirect the log to a file and peruse the file at our leisure.

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's enable query logging.

<details>
  <summary style="color:cyan"><b>What is query logging?</b></summary>
<hr style="background-color:cyan">
Sometimes it may be helpful to understand what queries Druid is fielding as well as who is making the queries.
Query logging gives us this information.
<br><br>
By default, query logging is disabled.
So, in the next couple of steps we enable query logging and restart Druid so that the configuration change takes effect.
<hr style="background-color:cyan">
</details>

Here's a command to enable query logging  (run this command in the _Shell_ tab).

```
sed -i 's/druid.startup.logging.logProperties=true/druid.startup.logging.logProperties=true\ndruid.request.logging.type=slf4j/' \
  /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/_common/common.runtime.properties
```

<details>
  <summary style="color:cyan"><b>What does this command do?</b></summary>
<hr style="background-color:cyan">
This command adds the following line to the common configuration file:
<br>
<code>druid.request.logging.type=slf4j</code>
<br>
This setting tells Druid to use the <a href="https://logging.apache.org/log4j/2.x/" target="_blank">Log4J2</a> logging utility.
Read more <a href="https://druid.apache.org/docs/latest/configuration/index.html#startup-logging" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 14</h2><hr style="color:cyan;background-color:cyan;height:5px">

Restart the cluster so the configuration change will take effect (run this command in the _Shell_ tab).

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>You may find it interesting to switch back and forth between the Shell tab and the Tail Shell tab so you can observe the log as Druid starts up.</i></p>
<hr style="background-color:cyan">

```
kill $(ps -ef | grep 'perl /root' | awk 'NF{print $2}' | head -n 1)
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -eq 0 ]; do echo "Waiting for cluster to terminate..."; sleep 3; done
nohup /root/apache-druid-24.0.0/bin/start-nano-quickstart > /root/log.out 2> /root/log.err < /dev/null & disown
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]; do echo "Waiting for cluster to initialize..."; sleep 3; done
```

<h2 style="color:cyan">Step 15</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, perform a query so we can investigate the query logging (run this command in the _Shell_ tab).

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | jq
```

<h2 style="color:cyan">Step 16</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can find the query logging at the end of the Broker log (run this command in the _Shell_ tab).

```
tail /root/apache-druid-24.0.0/log/broker.log -n 1
```

We see the query of the wikipedia table in the log indicating what the query was.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>We can configure logs to exclude sensitive information from log files.
Read more <a href="https://druid.apache.org/docs/latest/configuration/index.html#startup-logging" target="_blank">here</a>.</i></p>
<hr style="background-color:cyan">


<h2 style="color:cyan">To Summarize:</h2>

- Druid has process logs (stdout and status)
- Druid has task logs
- Druid can log queries


<h2 style="color:cyan">Great! Now we have been exposed to Druid's log files!</h2>


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
