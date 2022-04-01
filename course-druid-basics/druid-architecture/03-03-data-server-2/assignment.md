---
slug: 03-data-server-2
id: o5qyksvmb8is
type: challenge
title: Set Up the Second Data Server
teaser: Learn how to deploy the second of two data servers
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/3pj7z9gqvg
tabs:
- title: Data-2-shell
  type: terminal
  hostname: data-server-2
- title: Data-1-shell
  type: terminal
  hostname: data-server-1
- title: Master-shell
  type: terminal
  hostname: master-server
- title: Master-editor
  type: code
  hostname: master-server
  path: /root
difficulty: basic
timelimit: 600
---
In this challenge we will deploy the second of two data servers named _data-server-2_.
This server works just like data-server-1.

By adding more data servers, we not only increase the amount of storage, but we also bring more CPU to bare for query processing.


<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Download the Druid distribution.

```
wget https://ftp.wayne.edu/apache/druid/0.21.1/apache-druid-0.21.1-bin.tar.gz
```

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Unzip the downloaded file.

```
tar -xzf apache-druid-0.21.1-bin.tar.gz
```

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's copy the historical files into our cluster configuration.

```
cp /root/apache-druid-0.21.1/conf/druid/single-server/nano-quickstart/historical/* /root/apache-druid-0.21.1/conf/druid/cluster/data/historical
```

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's also copy the middle manager files into our cluster configuration.

```
cp /root/apache-druid-0.21.1/conf/druid/single-server/nano-quickstart/middleManager/* /root/apache-druid-0.21.1/conf/druid/cluster/data/middleManager
```

<br>
<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Again, let's copy the _common.runtime.properties_ file we edited in the first challenge so that the server knows how to contact ZooKeeper.

```
scp -o StrictHostKeyChecking=no master-server:/root/apache-druid-0.21.1/conf/druid/cluster/_common/common.runtime.properties /root/apache-druid-0.21.1/conf/druid/cluster/_common/common.runtime.properties
```

<br>
<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Now, we can launch the second data server.
Again, we'll use _nohup_ so that the processes continue to run when we move to the next challenge.

```
nohup /root/apache-druid-0.21.1/bin/start-cluster-data-server > /root/apache-druid-0.21.1/log.out 2> /root/apache-druid-0.21.1/log.err < /dev/null & disown
```

<br>
<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Check that the historical and middleManager processes are running.

```
ps -ef | grep "openjdk\-[8-8]" | awk 'NF{print $NF}'
```
<br>
<h2 style="color:cyan">Outstanding! You have deployed the second data server.</h2>