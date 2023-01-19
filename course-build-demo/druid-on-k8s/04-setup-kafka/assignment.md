---
slug: setup-kafka
id: 17wwjua6jxqb
type: challenge
title: Setup Kafka
teaser: See how to install Kafka and create a topic.
notes:
- type: text
  contents: Please wait while we set up the lab
tabs:
- title: Shell
  type: terminal
  hostname: server
- title: Druid Console
  type: service
  hostname: server
  path: /unified-console.html
  port: 8888
- title: Editor
  type: code
  hostname: server
  path: /root
difficulty: basic
timelimit: 600
---

<h2 style="color:cyan">Install Kafka and create a clickstream data topic</h2>

In this lab, we'll install Kafka and use the data generator from the previous lab to stream data to a Kafka Topic.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Install Kafka

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-kafka bitnami/kafka
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Launch Kafka.

```
kubectl run my-kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.2.1-debian-11-r4 --namespace default --command -- sleep infinity
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Monitor the Kafka pods. Wait for them to have a status of _Running_ with all containers ready (i.e., _1/1_).
Once the pods are ready, use _Ctrl-C_ to exit the watch loop.

```
watch kubectl get pods
```

ADD WAIT SCRIPT HERE

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a topic for the clickstream data.

```
kubectl exec --tty -i my-kafka-client -- /bin/bash \
  -c "kafka-topics.sh \
  --create \
  --topic clickstream_data \
  --bootstrap-server my-kafka.default.svc.cluster.local:9092"
```

<h2 style="color:cyan">Send clickstream data directly to Kafka</h2>


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start the data generation pod.

```
kubectl apply -f /root/DruidCloudPOC/driver-code/driver-code.yaml
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Test that the data generator is sending data to Kafka by running a generic Kafka consumer.
Once you see the data using the consumer, click _Ctrl-C_ to end the consumer.

```
kubectl exec --tty -i my-kafka-client -- /bin/bash \
  -c "kafka-console-consumer.sh \
    --bootstrap-server my-kafka.default.svc.cluster.local:9092 \
    --topic clickstream_data \
    --from-beginning"
```

<h2 style="color:cyan">Ingest data from Kafka</h2>

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:2px">

Using the Druid console, let's start ingesting the clickstream data.
Click on the _Druid Console_ tab.

PUT IMAGES OF INGESTION HERE

Boot-strap server:

```
my-kafka.default.svc.cluster.local:9092
```

Topic:
```
clickstream_data
```

<h2 style="color:cyan">Wow! We have installed Kafka and are sending data to it!</h2>


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
