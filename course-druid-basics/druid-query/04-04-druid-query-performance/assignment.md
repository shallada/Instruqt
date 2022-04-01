---
slug: 04-druid-query-performance
id: cue1qj33o6w8
type: challenge
title: Druid Query Performance
teaser: Let's investigate how queries impact Druid processes
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/u396m5ztlg
tabs:
- title: Shell
  type: terminal
  hostname: single-server
- title: Monitor
  type: terminal
  hostname: single-server
- title: Pivot
  type: service
  hostname: single-server
  path: /
  port: 9095
  new_window: true
- title: Editor
  type: code
  hostname: single-server
  path: /root
difficulty: basic
timelimit: 900
---
In this challenge, we want to do some queries and see the effects on the various Druid processes.


Before we do the queries, let's set up a monitoring system consisting of:
- A Bash shell script that monitors the druid processes and outputs events
- A Kafka system that routes the events
- A Kafka broker that consumes the events from Kafka and ingests them into a Druid table data source

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's run the Kafka broker in the background.

```
/root/kafka_2.13-2.7.0/bin/kafka-server-start.sh /root/kafka_2.13-2.7.0/config/server.properties > /dev/null &
```

Now, tell Kafka to create a topic named _druid-processes_.

<details>
  <summary style="color:cyan"><b>What is a Kafka topic?</b></summary>
<hr style="background-color:cyan">
<br>
Kafka is a stream processing system that allows data providers to stream data to consumer processes.
Providers stream data to topics, and consumers subscribe to topics to receive data.
Think of a topic as a stream-like version of a database table.
<hr style="background-color:cyan">
</details>

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create the topic.

```
/root/kafka_2.13-2.7.0/bin/kafka-topics.sh --create --topic druid-processes --bootstrap-server localhost:9092
```

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Set the following Kafka environment variable.

```
export KAFKA_OPTS="-Dfile.encoding=UTF-8"
```

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start the producer, and pipe the results into Kafka.

<details>
  <summary style="color:cyan"><b>How does this producer work?</b></summary>
<hr style="background-color:cyan">
<br>
This producer is a Bash shell script named <i>process-monitor-producer.sh</i> (feel free to open it in the editor and take a look).
This script uses the Linux <i>top</i> command in batch mode with an interval of a half-second.
Then, the script pulls out the druid-related processes and joins these, based on process ID, with the results of the <i>ps</i> command (to get the process names).
Finally, the script formats and outputs the results as JSON.
<br>
<br>
The command below takes the output from the shell script and pipes it into a Kafka script that publishes the events to a Kafka topic named <i>druid-processes</i>.
We run the entire command in the background to free up the terminal window.
We also pipe any remaining command output to <i>/dev/null</i> so it doesn't clutter up the screen.
<hr style="background-color:cyan">
</details>


```
/root/process-monitor-producer.sh | /root/kafka_2.13-2.7.0/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic druid-processes > /dev/null &
```

<br>
<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start the Druid ingestion.

<details>
  <summary style="color:cyan"><b>What does this command do?</b></summary>
<hr style="background-color:cyan">
<br>
If you have worked through the ingestion challenges, you will recognize that this command submits an ingestion spec to Druid.
This ingestion spec tells Druid how to connect to Kafka, how to interpret the incoming Kafka data, and how to store it in a Druid table data source.
<hr style="background-color:cyan">
</details>


```
curl -XPOST -H'Content-Type: application/json' -d @/root/kafka-ingestion-spec.json   http://localhost:8081/druid/indexer/v1/supervisor | jq
```

Now, we will run a Python program that queries our Druid database (using the Broker API) and plots the results of the query.

<br>
<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Here's the query the Python program uses.

<details>
  <summary style="color:cyan"><b>What does this query do?</b></summary>
<hr style="background-color:cyan">
<br>
This query retrieves Druid process utilization metrics (e.g., CPU and memory) for the most recent one minute of activity.
<hr style="background-color:cyan">
</details>

```
cat /root/query-wiki-activity-last-1-minute.json | jq
```

Here's the command to perform the query and plot the results.
We want to run this in a separate terminal so we can leave it running while we perform queries.

<br>
<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the _Monitor_ tab and run the query.
![Click Monitor](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/ClickMonitor.png)

```
python3 plot.py
```

<details>
  <summary style="color:cyan"><b>What does this graph show?</b></summary>
<hr style="background-color:cyan">
<br>
The graph shows the CPU usage for each of the five Druid processes.
The X axis represents time, with the most recent events on the left.
The Y axis is CPU usage in units that the Linux <i>top</i> command uses.
There is a line for each process, but due to the limits of character graphics, the lines in the front may hide the lines in the back.
<br>
<br>
The point of the graph is to show how much CPU (relatively) each process is consuming during operation.
Recall that the Broker process controls queries, so as queries happen, you should see its CPU usage increase.
Also, note that the plotting program is performing queries, which shows up on the graph.
<hr style="background-color:cyan">
</details>

You see that the Broker process exhibits more activity than the other processes.
This is because the Broker is fielding the polling requests from the graph plotting program.


It is important to understand that not all Druid queries behave the same way.
We might consider some Druid queries as anti-patterns, meaning these are types of queries we would like to avoid.


With the plotting program, we can observe the effects of anti-patterns on the Druid processes.
Any query not constrained by <i>__time</i>, such as _SELECT *_ with no _WHERE_ clause, is one such anti-pattern.

<br>
<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Back in the _Shell_ tab, let's run this anti-pattern query.


```
curl -X 'POST' -H 'Content-Type:application/json' -d @/root/select-star-wikipedia.json http://localhost:8888/druid/v2/sql > /dev/null
```

<br>
<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click back on the _Monitor_ tab and observe the effects of the anti-pattern query.

Now, look at the effects of the query on the processes.
Because this table data source is not very large (only one day of data), the effects of this anti-pattern query are not as severe as they would be for a larger table data source.
You are likely to see a slight spike in the Historical process activity and possible increased Broker process activity.
However, we are using the linux _top_ command to monitor CPU usage, and _top_ can be inaccurate on short spikes due to low sampling rates.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>If you run the query several times, you will probably not see any additional spikes in activity.
This is because Druid is caching the results.
<hr style="background-color:cyan">


These ASCII graphics are very primitive.
We have a better way to visualize these metrics using Imply's Pivot data visualization app.

<br>
<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:2px">

The following command will start Pivot in a separate browser tab.

![Launch Pivot](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/LaunchPivot.png)

<details>
  <summary style="color:cyan"><b>What is Pivot?</b></summary>
<hr style="background-color:cyan">
<br>
Pivot is a visualization application that is part of the Imply product suite.
You  may have noticed that for this track we have been running Imply's products rather than open source Druid.
This is so we could use the Pivot product to visualize the metrics we have been gathering.
<hr style="background-color:cyan">
</details>

We have configured a Pivot dashboard just for this application.

<br>
<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:2px">

To view the dashboard, click as shown.

![View Dashboard](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/ViewDashboard.png)

Explore the dashboard.
You will see that it updates every five seconds.
- The top-left shows the relative CPU utilization.
- The bottom-left shows the per process memory utilization as a barchart.
- The top-right shows the mean CPU utilization over the one minute plotting period as a timeline.
- The middle-right chart is the maximum CPU utilization measured during the plotting period as a timeline.
- The bottom-right shows per process memory utilization as a timeline.

![Pivot Dashboard](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/PivotDashboard.png)

It will become important to understand Druid patterns and anti-patterns so that you get the most out of your Druid cluster.

<br>
<h2 style="color:cyan">Hey! This is epic!</h2>