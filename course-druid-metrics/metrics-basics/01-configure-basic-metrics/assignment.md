---
slug: configure-basic-metrics
id: pihpbdzdxvya
type: challenge
title: Configure Basic Druid Metrics
teaser: Learn to set up Druid to collect performance metrics
notes:
- type: video
  url: ../assets/01-DruidMetricsBasics.mp4
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

Let's see how basic metrics look.
We can start by looking just at the JVM metrics.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We need to modify the Druid configuration to enable metrics.
This lab environment uses the nano-quickstart configuration.
So in the _Editor_ tab, expand the folders and open _common.runtime.properties_ file in the _conf_ folder.

<a href="#img-1">
  <img alt="Open Config" src="../assets/OpenConfig.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Open Config" src="../assets/OpenConfig.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Enable emitting metrics to the log files by changing _druid.emitter_ (in the _Monitoring_ section) to _logging_.

```
druid.emitter=logging
```

<details>
  <summary style="color:cyan"><b>What do the three configuration settings do?</b></summary>
<hr style="background-color:cyan">
The first setting, <i>druid.monitoring.monitors</i>, determines which metrics Druid emits.
The default only emits JVM metrics.
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Some monitors may only apply to specific Druid process and should be configured in the process-specific configuration files.</i></p>
The second setting, <i>druid.emitter</i>, determines the target of the metrics output.
The default is <i>noop</i>, which specifies no metrics output, but here we are sending metrics to the log files. Other emitters target different outputs, e.g., an HTTP server.
<br><br>
The third setting, <i>druid.emitter.logging.logLevel</i>, tells Druid what logging security level to use when emitting metrics.
<br><br>
Read more <a href="https://druid.apache.org/docs/latest/configuration/index.html#enabling-metrics" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<a href="#img-2">
  <img alt="Change Emitter" src="../assets/ChangeEmitter.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Change Emitter" src="../assets/ChangeEmitter.png" />
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

Back in the _Shell_ tab, use the following commands to launch Druid and wait for Druid to initialize.

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

By default, Druid emits metrics every minute (Read about _druid.monitoring.emissionPeriod_ <a href="https://druid.apache.org/docs/latest/configuration/index.html#enabling-metrics" target="_blank">here</a>).
So if we look in the logs now, we will not see metrics yet.


Let's wait for Druid to emit some metrics.

```
while [ $(grep -C 2 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log | wc -l) -eq 0 ]
do
  echo "Waiting for Druid to emit metrics..."
  sleep 5
done
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Druid emits the metrics into the processes' log files.
The following commands show us an example of metrics in the context of the log file.

```
grep -C 2 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log \
  | head -n 5
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>In this lab we will look at metrics only in the Broker log.
However, Druid emits similar JVM metrics to all the processes' log files.
But remember, unlike JVM metrics, there are some metrics that we can only gather from specific processes.</i></p>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can extract just the JSON from the metric and format the JSON by using the following commands.

<details>
  <summary style="color:cyan"><b>Why do we want to extract only the JSON?</b></summary>
<hr style="background-color:cyan">
As we have previously seen, the metrics messages are scattered among the other log messages.
As a result, the metrics contain the normal log message boiler plate.
But, when we are interested in zooming in on the metrics, this boiler plate is not helpful.
So, we extract the JSON portion of the log message, which focuses on the metrics information that we care about.
<hr style="background-color:cyan">
</details>

```
grep 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log \
  | head -n 1 \
  | awk 'BEGIN {FS = " - "} ; {print $2}' \
  | jq 'select(has("type") | not) | select(.feed == "metrics")'
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the previous step, we saw an example of a single JSON metric.
Let’s use a similar command line filter to extract all the metrics from the log file.
We can extract the timestamps, the metric names, and associated values for all metrics (in tabular format) using the following commands.

```
grep 'org.apache.druid.java.util.emitter.core.LoggingEmitter - [{]' apache-druid-24.0.0/log/broker.log \
  | awk 'BEGIN {FS = " - "} ; {print $2}' \
  | jq 'select(has("type") | not) | select(.feed == "metrics") | "\(.timestamp) \(.metric) \(.value)"' \
  | awk '{printf "%17.17s - %-30s %s\n", $1, $2, $3}'
```

Given this tabular perspective of the metrics, we get a sense of what metrics are – timestamped and labeled values for the part of Druid we are monitoring.


<h2 style="color:cyan">Great, we see how basic metrics work!</h2>


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
