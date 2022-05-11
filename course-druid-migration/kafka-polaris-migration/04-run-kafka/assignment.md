---
slug: run-kafka
id: wlrtrrwstkuz
type: challenge
title: Set Up Kafka
teaser: Let's get the Kafka pipeline set up with a produce and consumer.
notes:
- type: video
  url: ../assets/04-SetupKafka.mp4
tabs:
- title: Shell
  type: terminal
  hostname: single-server
- title: Editor
  type: code
  hostname: single-server
  path: /root
difficulty: basic
timelimit: 600
---

Run Kafka and see the output using _kafkacat_.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's run the Kafka broker in the background.

```
/root/kafka_2.13-2.7.0/bin/kafka-server-start.sh /root/kafka_2.13-2.7.0/config/server.properties > /dev/null &
```

Now, tell Kafka to create a topic named _process-monitor_.

<details>
  <summary style="color:cyan"><b>What is a Kafka topic?</b></summary>
<hr style="background-color:cyan">
Kafka is a stream processing system that allows data providers to stream data to consumer processes.
Providers stream data to topics, and consumers subscribe to topics to receive data.
Think of a topic as a stream-like version of a database table.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create the topic.

```
/root/kafka_2.13-2.7.0/bin/kafka-topics.sh --create --topic process-monitor --bootstrap-server localhost:9092
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Set the following Kafka environment variable.

```
export KAFKA_OPTS="-Dfile.encoding=UTF-8"
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start the producer, and pipe the results into Kafka.

<details>
  <summary style="color:cyan"><b>How does this producer work?</b></summary>
<hr style="background-color:cyan">
This producer is a Bash shell script named <i>process-monitor-producer.sh</i> (feel free to open it in the editor and take a look).
This script uses the Linux <i>top</i> command in batch mode with an interval of a half-second.
Then, the script pulls out the processes and joins these, based on process ID, with the results of the <i>ps</i> command (to get the process names).
Finally, the script formats and outputs the results as JSON.
<br>
<br>
The command below takes the output from the shell script and pipes it into a Kafka script that publishes the events to a Kafka topic named <i>process-monitor</i>.
This command will sample the processes 10 times and create events for each process in the Kafka topic.
<hr style="background-color:cyan">
</details>


```
/root/process-monitor-producer.sh ISO JSON 10 | \
  /root/kafka_2.13-2.7.0/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic process-monitor
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Read the events from from the Kafka topic.

```
/root/kafka_2.13-2.7.0/bin/kafka-console-consumer.sh --topic process-monitor --from-beginning --bootstrap-server localhost:9092
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Use _Ctrl-C_ to exit the Kafka message consumer.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span>
<i>In this challenge, the producer will only create a fixed number of records/messages.
Once the Kafka consumer has read the produced records, the consumer will appear to hang waiting for more messages, which is why we need to manually stop the program.
<br><br>
In the next challenge, we will run the producer for several minutes to produce more records.
But, you could imagine the producer running non-stop, and the Python program being able to read all these records from the Kafka topic!
<hr style="background-color:cyan">


<h2 style="color:cyan">Outstanding! You have set up Kafka!</h2>


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
