---
slug: clarity-ingestion
id: yeyypvhtxopi
type: challenge
title: Create a Workload
teaser: Let's create a workload and use Clarity to review Druid metrics
notes:
- type: video
  url: ../assets/07-ClarityIngestion.mp4
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

In this exercise, we'll use an open-source Druid data generator to provide a streaming ingestion workload that simulates clickstream data.

<details>
  <summary style="color:cyan"><b>Tell me more about this clickstream data</b></summary>
<hr style="background-color:cyan">
The open-source data generator outputs simulated events.
In this example, we'll configure the generator to simulate website traffic data by simulating users perusing an e-commerce website.
The configuration specifies a state machine that corresponds to users navigating a website, where each state represents a page.
Simulated users move from state to state probabilistically as shown in this image of the state machine.
<a href="#img-0">
  <img alt="Clickstream State Machine" src="../assets/ClickstreamStateMachine.png" />
</a>
<a href="#" class="lightbox" id="img-0">
  <img alt="Clickstream State Machine" src="../assets/ClickstreamStateMachine.png" />
</a>
At each transition, the state machine emits an event.
We will direct these events to a Kafka topic named <i>clickstream-data</i> and then perform a stream ingestion with Druid.
Read about the data generator <a href="https://github.com/implydata/druid-datagenerator" target="_blank">here</a>.
Also, feel free to inspect the example clickstream configuration file <a href="https://github.com/implydata/druid-datagenerator/blob/main/examples/clickstream_config.json" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's grab the data generator from its GitHub repo.

```
git clone https://github.com/implydata/druid-datagenerator.git
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

We'll modify the example clickstream configuration to send records to a Kafka topic named _clickstream-data_.

```
sed -i 's/"target": {"type": "stdout"}/"target": {"type": "kafka", "endpoint": "localhost:9092", "topic": "clickstream-data"}/g' \
  /root/druid-datagenerator/examples/clickstream_config.json
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We need to create the Kafka topic named _clickstream-data_.

```
/root/kafka_2.13-2.7.0/bin/kafka-topics.sh --create --topic clickstream-data --bootstrap-server localhost:9092
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start the data generator in the background.

```
nohup python3 /root/druid-datagenerator/DruidDataDriver.py -f /root/druid-datagenerator/examples/clickstream_config.json 2> /dev/null > /dev/null & disown
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

At this point, the data generator is pumping click-stream events into the Kafka topic named _clickstream-data_.


Let's start Druid streaming the click-stream events from Kafka into a Druid table datasource also named _clickstream-data_.
Use the following command to instruct Druid to begin the streaming ingestion.

```
curl -XPOST \
  -H'Content-Type: application/json' \
  -d@/root/clickstream-ingestion.json \
  http://localhost:8090/druid/indexer/v1/supervisor
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's review some of the ingestion metrics using Clarity.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>It may take a minute or two before Druid creates the streaming table datasource and ingests some of the streaming data.</i>
<hr style="background-color:cyan">

Click on the Clarity tab.


In the left section of the Clarity display, there is a list of various metrics views subdivided into subsections of _QUERIES_, _INGESTION_, _SERVER_, and _EXCEPTIONS_.

Click on, and review, each of the views in the _INGESTION_ section on the left.

<a href="#img-6">
  <img alt="Ingestion Overview" src="../assets/IngestionOverview.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Ingestion Overview" src="../assets/IngestionOverview.png" />
</a>

These are helpful preconfigured views. We can customize these views, or create views of our own from scratch.


<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's look at how we can create custom views.
Click on the hamburger menu in the top-left corner of the display, then select _Ingestion_.

<a href="#img-7">
  <img alt="Ingestion Views" src="../assets/IngestionViews.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Ingestion Views" src="../assets/IngestionViews.png" />
</a>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can set the refresh rate and time scale by clicking as shown.

<a href="#img-8">
  <img alt="Setup Time" src="../assets/SetupTime.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Setup Time" src="../assets/SetupTime.png" />
</a>


<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the top-middle of the display we see sections for filtering and showing metrics.
Let's add the _Data Source_ dimension to the display.

<a href="#img-9">
  <img alt="Add Datasource" src="../assets/AddDatasource.png" />
</a>
<a href="#" class="lightbox" id="img-9">
  <img alt="Add Datasource" src="../assets/AddDatasource.png" />
</a>

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can slice and dice our view by selecting from the panel on the right of the display.

<a href="#img-10">
  <img alt="Toggle Datasource" src="../assets/ToggleDatasource.png" />
</a>
<a href="#" class="lightbox" id="img-10">
  <img alt="Toggle Datasource" src="../assets/ToggleDatasource.png" />
</a>

<h2 style="color:cyan">Cool! We see the ingestion metrics that Clarity provides and how to explore them!</h2>



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
