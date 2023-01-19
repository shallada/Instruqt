---
slug: install-msq
id: jjn1jba0lxy7
type: challenge
title: Install Druid with the Multi-Stage Query Framework
teaser: Learn how to install Druid with the MSQ framework
notes:
- type: video
  url: ../assets/01-InstallMSQ.mp4
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
<h2 style="color:cyan">Install and configure Druid 24.0 release</h2>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Use the following command to get the Druid 24.0 release.

```
wget https://ftp.wayne.edu/apache/druid/24.0.0/apache-druid-24.0.0-bin.tar.gz
tar -xzf apache-druid-24.0.0-bin.tar.gz
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Modify the MiddleManager properties file to increase resources.

```
sed -i 's/druid.worker.capacity=2/druid.worker.capacity=4/g' \
  /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/middleManager/runtime.properties
echo -e "# Set this property to the maximum number of tasks per job plus 25.\n\
# The upper limit for tasks per job is 1000, so 1000 + 25.\n\
# Set this lower if you do not intend to use this many tasks.\n\
druid.indexer.fork.property.druid.server.http.numThreads=1025\n\
\n\
# Lazy initialization of the connection pool that was used for shuffle.\n\
druid.global.http.numConnections=50\n\
druid.global.http.eagerInitialization=false" \
  >> /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/middleManager/runtime.properties
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start Druid in the background.

```
/root/apache-druid-24.0.0/bin/supervise -c /root/apache-druid-24.0.0/conf/supervise/single-server/nano-quickstart.conf > druid.log &
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Wait for Druid to come up.
This command will delay until Druid is completely running.

```
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]; do echo -n '.' && sleep 1; done && echo -e "\nClick the Druid Console tab above"
```

<h2 style="color:cyan">Now, let's run an example query in the Druid Console tab to show that Druid is operational.</h2>
<br>
<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>This example query is an external query, which is a new feature in the MSQ framework.
External queries read data from an external file instead of a Druid datasource.
This is not a common use-case, but it may be helpful from time to time.
<br><br>
We will build on this external query later to create an ingestion.</i></p>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Druid Console_ tab.

<a href="#img-5">
  <img alt="Click Druid Console" src="../assets/ClickDruidConsole.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Click Druid Console" src="../assets/ClickDruidConsole.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Query_ tab.

<a href="#img-6">
  <img alt="Click Query Tab" src="../assets/ClickQueryTab.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Click Query Tab" src="../assets/ClickQueryTab.png" />
</a>


<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Copy and paste the following query.

```
SELECT *
FROM TABLE(
  EXTERN(
    '{"type": "http", "uris": ["https://static.imply.io/gianm/wikipedia-2016-06-27-sampled.json"]}',
    '{"type": "json"}',
    '[{"name": "added", "type": "long"}, {"name": "channel", "type": "string"}, {"name": "cityName", "type": "string"}, {"name": "comment", "type": "string"}, {"name": "commentLength", "type": "long"}, {"name": "countryIsoCode", "type": "string"}, {"name": "countryName", "type": "string"}, {"name": "deleted", "type": "long"}, {"name": "delta", "type": "long"}, {"name": "deltaBucket", "type": "string"}, {"name": "diffUrl", "type": "string"}, {"name": "flags", "type": "string"}, {"name": "isAnonymous", "type": "string"}, {"name": "isMinor", "type": "string"}, {"name": "isNew", "type": "string"}, {"name": "isRobot", "type": "string"}, {"name": "isUnpatrolled", "type": "string"}, {"name": "metroCode", "type": "string"}, {"name": "namespace", "type": "string"}, {"name": "page", "type": "string"}, {"name": "regionIsoCode", "type": "string"}, {"name": "regionName", "type": "string"}, {"name": "timestamp", "type": "string"}, {"name": "user", "type": "string"}]'
  )
)
LIMIT 100
```

<details>
  <summary style="color:cyan"><b>What does <i>EXTERN<i/> do?</b></summary>
<hr style="background-color:cyan">
The <i>EXTERN<i/> clause tells Druid to use an external data source (such as a file) rather than a Druid table as the basis for the query.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click _Run_ to execute the query, which takes about 30 seconds to run.

<a href="#img-8">
  <img alt="Run External Query" src="../assets/RunExtQuery.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Run External Query" src="../assets/RunExtQuery.png" />
</a>

<h2 style="color:cyan">Great! You have Druid running with MSQ!</h2>


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
