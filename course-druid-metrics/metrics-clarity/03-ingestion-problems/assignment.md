---
slug: ingestion-problems
id: iqzb9nle9cli
type: challenge
title: Metrics for Ingestion Problems
teaser: Let's learn what metrics can show us about ingestion problems
notes:
- type: video
  url: ../assets/0X-IngestionMetricsAnamolies.mp4
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

In the previous lab we set up a data generator and began ingesting data into Druid via a Kafka topic.


Let's cause some ingestion problems for Druid so we can investigate the problems using metrics.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

For our first problem, let's inject some poorly formed (non-parsable) records into the Kafka topic.

```
echo "This is a poorly formed record" \
  | /root/kafka_2.13-2.7.0/bin/kafka-console-producer.sh \
  --broker-list localhost:9092 \
  --topic clickstream-data
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

We will need to wait a minute for the metrics to be emitted.
Then, in the _Clarity_ tab, click on the _Ingestion Overview_ view.

<a href="#img-2">
  <img alt="See Unparseable Event" src="../assets/SeeUnparseableEvent.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="See Unparseable Event" src="../assets/SeeUnparseableEvent.png" />
</a>


If you have waited for Druid to emit metrics, you will see the count of unparseable events is now one (refresh and repeat if necessary).

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can also see the unparseable event from the _Events by Time_ view.

<a href="#img-3">
  <img alt="Events By Time" src="../assets/EventsByTime.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Events By Time" src="../assets/EventsByTime.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's cause a disruption in the ingestion pipeline.
We will pause the Kafka broker for a minute, and then restart it.


In the _Shell_ tab, execute the following.

```
KAFKA_PID=$(ps -ef | grep kafka.Kafka | head -n 1 | awk 'NF{print $2}')
kill -STOP $KAFKA_PID
sleep 60
kill -CONT $KAFKA_PID
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Clarity_ tab if we wait a minute or two, we can see the disruption in the _Events by Time_ view (we may have to refresh repeatedly to see the disruption).


<a href="#img-3">
  <img alt="See KafkaP ause" src="../assets/SeeKafkaPause.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="See Kafka Pause" src="../assets/SeeKafkaPause.png" />
</a>

If we are patient enough to wait a couple of minutes after the disruption, we will see a dip during the pause, followed by a spike as the ingestion process catches up.

<h2 style="color:cyan">Great! We can use metrics to investigate ingestion problems!</h2>



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
