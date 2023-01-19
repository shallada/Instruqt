---
slug: configure-system-monitors
id: k8npfeccp4mt
type: challenge
title: Configure System-wide Druid Monitors
teaser: Learn what monitors we can apply across all Druid processes
notes:
- type: video
  url: ../assets/02-MetricsMonitors.mp4
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

We can use monitors to augment the metrics that Druid emits.

<details>
  <summary style="color:cyan"><b>What are Druid monitors?</b></summary>
<hr style="background-color:cyan">
Monitors are extensions we can add to Druid to capture more metrics.
<br><br>
Even with no monitors added, Druid produces a basic set of metrics (of course, we need to configure the metrics emitter to enable metrics as we saw in the previous lab).
By Default, Druid adds a JVM monitor to enable JVM-related metrics, which are very useful for understanding Druid's performance.
We can also add other monitors if we want to focus on the performance of specific Druid behaviors.
<br><br>
Read about the default metrics, as well as metrics that require monitor extensions <a href="https://druid.apache.org/docs/latest/operations/metrics.html" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


Let's start by exploring the most basic metrics.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We need to modify the Druid configuration to enable metrics.
In the _Editor_ tab, expand the necessary folders and open _common.runtime.properties_.

<a href="#img-1">
  <img alt="Open Config" src="../assets/OpenConfig.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Open Config" src="../assets/OpenConfig.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Remove the default JVM monitor, and configure the emitter to use the log files by replacing the following lines.

```
druid.monitoring.monitors=[]
druid.emitter=logging
```

<a href="#img-2">
  <img alt="Empty Monitor List" src="../assets/EmptyMonitorList.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Empty Monitor List" src="../assets/EmptyMonitorList.png" />
</a>


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the file.

<a href="#img-3">
  <img alt="Save Config" src="../assets/SaveConfig.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Save Config" src="../assets/SaveConfig.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start Druid and wait for Druid to initialize using the following commands in the _Shell_ tab.

```
nohup /root/apache-druid-24.0.0/bin/start-nano-quickstart \
  > /root/log.out 2> /root/log.err \
  < /dev/null & disown
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]
do
  echo "Waiting for Druid to initialize..."
  sleep 3
done
```


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's wait for Druid to emit some metrics.
Remember, By default Druid emits metrics every minute.

```
while [ $(grep -C 2 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log | wc -l) -eq 0 ]
do
  echo "Waiting for Druid to emit metrics..."
  sleep 5
done
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can investigate the Broker's metrics in table format by using the following command.

```
grep 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log \
  | awk 'BEGIN {FS = " - "} ; {print $2}' \
  | jq 'select(has("type") | not) | select(.feed == "metrics") | "\(.timestamp) \(.metric) \(.value)"' \
  | awk '{printf "%17.17s - %-30s %s\n", $1, $2, $3}'
```

We see _Jetty_ and _Avatica_ messages.
If you’re familiar with Druid, you’ll know that <i><a href="https://www.eclipse.org/jetty/" target="_blank">Jetty</a></i> is what Druid uses for all its web services, and <i><a href="https://calcite.apache.org/avatica/" target="_blank">Avatica</a></i> is a JDBC driver from <i><a href="https://calcite.apache.org/" target="_blank">Apache Calcite</a></i>, which is used for SQL query parsing and planning.
These metrics are the basic metrics that the Broker always emits.


<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's ingest some sample data.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')

  while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
    | jq .multiStageQuery.payload.status.status 2> /dev/null \
    | grep SUCCESS | wc -w) -eq 0 ]; \
    do
      echo "Waiting for ingestion to complete..."
       sleep 3
    done
  echo "Ingestion completing"
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Also, we can perform a query so we can see some query-related metrics.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | jq
```

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Look again to see the query metrics.

```
echo "Waiting one minute to ensure that Druid emits the query metrics..."
sleep 60
grep 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log \
  | awk 'BEGIN {FS = " - "} ; {print $2}' \
  | jq 'select(has("type") | not) | select(.feed == "metrics") | "\(.timestamp) \(.metric) \(.value)"' \
  | awk '{printf "%17.17s - %-30s %s\n", $1, $2, $3}'
```

Now, you will notice _sqlQuery_ metrics reflecting the query we performed.

<details>
  <summary style="color:cyan"><b>What do the <i>sqlMetrics</i> tell us?</b></summary>
<hr style="background-color:cyan">
There are three SQL related metrics:
<ul>
<li>time</li>
<li>planningTimeMs</li>
<li>bytes</li>
</ul>
Read more <a href="https://druid.apache.org/docs/latest/operations/metrics.html#sql-metrics" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>In the <a href="https://druid.apache.org/docs/latest/operations/metrics.html#sql-metrics" target="_blank">documentation</a>, you will notice that each metric has a list of "Dimensions".
These "Dimensions" are the fields within the JSON metrics record.
In this step, the jq command in the pipeline filters out all but the timestamp, label (i.e., metric) and value fields.
The other fields maybe helpful for deeper dives into metrics, but in this exercise, we just want to get a sense of what changes when we add monitors.</i></p>
<hr style="background-color:cyan">



Now, let's add the JVM metrics that were part of Druid's default configuration.


<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Editor_ tab, let's edit the _common.runtime.properties_ file again and add in the JVM monitor by replacing the following line.

```
druid.monitoring.monitors=["org.apache.druid.java.util.metrics.JvmMonitor"]
```

<a href="#img-10">
  <img alt="Add Jvm Monitor" src="../assets/AddJvmMonitor.png" />
</a>
<a href="#" class="lightbox" id="img-10">
  <img alt="Add Jvm Monitor=" src="../assets/AddJvmMonitor.png" />
</a>

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the file.

<a href="#img-11">
  <img alt="Save Config" src="../assets/SaveConfig.png" />
</a>
<a href="#" class="lightbox" id="img-11">
  <img alt="Save Config" src="../assets/SaveConfig.png" />
</a>


<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

Restart the cluster so the configuration change will take effect (run this command in the _Shell_ tab).


```
kill $(ps -ef | grep 'perl /root' | awk 'NF{print $2}' | head -n 1)
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -eq 0 ]; do echo "Waiting for cluster to terminate..."; sleep 3; done
nohup /root/apache-druid-24.0.0/bin/start-nano-quickstart > /root/log.out 2> /root/log.err < /dev/null & disown
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]; do echo "Waiting for cluster to initialize..."; sleep 3; done; sleep 5
```

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">


Finally, wait a minute (for the Broker to emit metrics) and then let's look at the Broker's metrics again to see what has changed.

```
sleep 60
grep 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log \
  | awk 'BEGIN {FS = " - "} ; {print $2}' \
  | jq 'select(has("type") | not) | select(.feed == "metrics") | "\(.timestamp) \(.metric) \(.value)"' \
  | awk '{printf "%17.17s - %-30s %s\n", $1, $2, $3}'
```

We see that adding the JVM monitor causes the Broker to emit metrics specific to the JVM.


<details>
  <summary style="color:cyan"><b>What metrics does <i>JvmMonitor</i> emit?</b></summary>
<hr style="background-color:cyan">
The JVM metrics include metrics relating to:
<ul>
<li>Thread pools</li>
<li>Buffer pools</li>
<li>Memory utilization</li>
<li>Garbage collection</li>
</ul>
Read more <a href="https://druid.apache.org/docs/latest/operations/metrics.html#jvm" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>



<h2 style="color:cyan">Cool! We see basic metrics and how to augment them!</h2>


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
