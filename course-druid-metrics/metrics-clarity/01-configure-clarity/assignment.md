---
slug: configure-clarity
id: u2oihkdidogb
type: challenge
title: Configure Clarity
teaser: Let's configure Clarity to view Druid metrics
notes:
- type: video
  url: ../assets/06-VisualizeMetrics.mp4
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

In this lab, we will use Imply's distribution of Druid which includes Pivot and Clarity.
Because of licensing complexities within the educational environment, we have already installed and configured these apps for you.
But in this exercise, we will review how we configured Druid, Pivot and Clarity in case you want to reproduce this in your own cluster.

<details>
  <summary style="color:cyan"><b>What is Pivot?</b></summary>
<hr style="background-color:cyan">
Pivot Imply's product that provides highly interactive Druid data querying and visualization.
Read more <a href="https://imply.io/imply-pivot/" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


<details>
  <summary style="color:cyan"><b>What is Clarity?</b></summary>
<hr style="background-color:cyan">
Clarity is Imply's product for interactively analyzing and visualizing Druid metrics.
Read more <a href="https://imply.io/performance-monitoring/" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We'll start by seeing that we added the _clarity-emitter-kafka_ extension to the extensions load list.
The following command shows us the load list.

```
grep 'druid.extensions.loadList=' /root/imply-2022.11/conf-quickstart/druid/_common/common.runtime.properties
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, we modified the Druid emitter to use the _clarity-emitter-kafka_ extension.
Use the following command to review these modifications.

```
grep 'druid.emitter' /root/imply-2022.11/conf-quickstart/druid/_common/common.runtime.properties
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We also modified Pivot for collecting Druid metrics.
Run the following command to see these modifications.

```
grep -A 6 '# Specify the metrics cluster to connect to' /root/imply-2022.11/conf-quickstart/pivot/config.yaml
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Given that configuration, we started Druid.
Use the following command to review the running processes.

```
ps -ef | grep "Main server [A-Za-z]*$" | awk 'NF{print $NF}'
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's run the Kafka broker in the background.

<details>
  <summary style="color:cyan"><b>Why are we running Kafka?</b></summary>
<hr style="background-color:cyan">
Given our configuration, Druid will emit metrics to a Kafka topic named <i>druid-metrics</i>.
Then, we will ingest these metrics from the topic back into Druid.
<br><br>
In our case for training purposes, we will use a single Druid server both to emit and to ingest metrics.
In a production environment, you would want to set up a separate Druid cluster to ingest metrics only.
This two-cluster configuration reduces load on the main production cluster and also does not contaminate the metrics with metrics-related activity.
So in a production environment, Kafka forms a metrics bridge between the two Druid clusters.
<hr style="background-color:cyan">
</details>


```
nohup /root/kafka_2.13-2.7.0/bin/kafka-server-start.sh /root/kafka_2.13-2.7.0/config/server.properties 2> /dev/null > /dev/null & disown
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

To consume metrics from Kafka into Druid, we need to direct Druid to start a supervisor task to ingest the data.
Use the following command to start a streaming ingestion of metrics from Kafka into a Druid table datasource named _druid-metrics_.

```
curl -XPOST \
  -H'Content-Type: application/json' \
  -d@/root/clarity-kafka-supervisor.json \
  http://localhost:8090/druid/indexer/v1/supervisor
```


<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's verify the metrics are streaming into the Druid table datasource named _druid-metrics_.


It may take a minute for Druid to create the table datasource from the Kafka stream, but once Druid has created the datasource, we can view the datasource using Pivot to verify it exists.

Click on the Pivot tab, and then click on the _Data_ tab within Pivot.
If you don't see _druid-metrics_ listed, wait a few seconds, refresh the Pivot tab as shown and click on the _Data_ tab again.

<a href="#img-7">
  <img alt="View Pivot Datasources" src="../assets/ViewPivotDatasources.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="View Pivot Datasources" src="../assets/ViewPivotDatasources.png" />
</a>

Remember, because the source of our metrics data is Druid, it appears as a table that we can see and query using tools like Pivot, the Druid console or even Druid's APIs.
In this step, we used Pivot to verify the table exists, but feel free to use Pivot to inspect the data in the table if you are interested.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Once the _druid-metrics_ datasource appears in Pivot, you can click the Clarity tab to begin to view the metrics.

<a href="#img-8">
  <img alt="Click Clarity" src="../assets/ClickClarity.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Click Clarity" src="../assets/ClickClarity.png" />
</a>


Feel free to spend a couple of minutes exploring Clarity, its views and features.
The metrics aren't very interesting at this point because there is no load on the Druid cluster.
We'll fix that in the next exercise.

<h2 style="color:cyan">Great! Druid, Pivot and Clarity are running!</h2>



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
