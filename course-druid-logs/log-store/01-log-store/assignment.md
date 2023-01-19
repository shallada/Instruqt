---
slug: log-store
id: gzrlqjnkw3eb
type: challenge
title: Druid Task Log Storage
teaser: Learn how to move task logs to long-term storage
notes:
- type: video
  url: ../assets/07-DruidTaskLogStorage.mp4
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
timelimit: 900
---

Let's use MinIO for both deep storage (for segments), and long term storage (for task logs).

<details>
  <summary style="color:cyan"><b>What is MinIO?</b></summary>
<hr style="background-color:cyan">
MinIO is an S3 compatible object store.
S3, which is Amazon's native object store, has become the de facto standard for object storage.
<br><br>
We can use MinIO to simulate S3 in our educational environment.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's set up a MinIO object store alias.

<details>
  <summary style="color:cyan"><b>What does this command do?</b></summary>
<hr style="background-color:cyan">
<i>mc</i> is the MinIO Client command line interface.
The sub-command <i>alias set</i> creates a mapping between the name <i>local</i> and an endpoint with associated credentials.
Once we have set the alias, we can reference it with just the name (as you will see in later commands).
<hr style="background-color:cyan">
</details>

```
mc alias set local http://localhost:9000 minioadmin minioadmin
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Create a service account.

<details>
  <summary style="color:cyan"><b>What is a service account and why do I want to create one?</b></summary>
<hr style="background-color:cyan">
A service account is a set of credentials we can use to access the object store.
Here we use the access key <i>access123</i> with the secret key <i>secret1234567890</i> to access the <i>local</i> endpoint.
<br><br>
We set up the service account so we don't expose the MinIO administrator credentials to the user (which in this case is Druid).
<hr style="background-color:cyan">
</details>

```
mc admin user svcacct add local minioadmin --access-key access123   --secret-key secret1234567890
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Set up a bucket named _druidlocal_.

<details>
  <summary style="color:cyan"><b>What is a bucket?</b></summary>
<hr style="background-color:cyan">
A bucket is a container for objects within the object store.
<hr style="background-color:cyan">
</details>

```
mc mb local/druidlocal
```

With MinIO set up, we will configure Druid to use this store for both segments and <a href="https://druid.apache.org/docs/latest/ingestion/tasks.html#task-logs" target="_blank">task logs</a>.


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">


In the editor, open Druid's common runtime config file.
We are running the _nano-quickstart_, so be sure to open that configuration file.

<a href="#img-4">
  <img alt="Open Config" src="../assets/OpenConfig.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Open Config" src="../assets/OpenConfig.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Add _druid-s3-extensions_ to the end of the extensions list.
Read more about S3 extension configuration <a href="https://druid.apache.org/docs/latest/development/extensions-core/s3.html" target="_blank">here</a>.

```
"druid-s3-extensions"
```

<a href="#img-5">
  <img alt="Add S3 Extension" src="../assets/AddS3Ext.png" /><br>
  <center>(Click to enlarge)</center>
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Add S3 Extension" src="../assets/AddS3Ext.png" />
  <center>(Click to return)</center>
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Use the following configuration to enable S3 deep storage of segments (see the image below for additional help).
Strictly speaking, we don't have to enable S3 deep storage to use the logs, but since we are simulating using S3, we'll go ahead and do this.


```
druid.storage.type: s3
druid.storage.bucket: druidlocal
druid.storage.baseKey: druid/segments
druid.s3.accessKey: access123
druid.s3.secretKey: secret1234567890
druid.s3.forceGlobalBucketAccessEnabled: false
druid.storage.disableAcl: true
druid.s3.enablePathStyleAccess: true
druid.s3.endpoint.signingRegion: us-east-1
druid.s3.endpoint.url: http://localhost:9000
druid.s3.protocol: http
druid.s3.enablePathStyleAccess: true
```

<a href="#img-6">
  <img alt="Configure Deep Store" src="../assets/ConfigureDeepStore.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Configure Deep Store" src="../assets/ConfigureDeepStore.png" />
</a>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Use the following configuration to enable S3 long-term storage of task logs (see the image below for additional help).
Read more about task log configuration <a href="https://druid.apache.org/docs/latest/configuration/index.html#task-logging" target="_blank">here</a>.

```
druid.indexer.logs.type: s3
druid.indexer.logs.s3Bucket: druidlocal
druid.indexer.logs.s3Prefix: druid/logs
druid.indexer.logs.disableAcl: true
```

<a href="#img-7">
  <img alt="Configure Long-term Store" src="../assets/ConfigureLongStore.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Configure Long-term" src="../assets/ConfigureLongStore.png" />
</a>


<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the changes to the configuration.

<a href="#img-8">
  <img alt="Save Config" src="../assets/SaveConfig.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Save Config" src="../assets/SaveConfig.png" />
</a>


<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

In this lab, Druid is not yet started,
So back in the _Shell_ tab, start Druid using the following commands.


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

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can use the process logs to verify our changes were applied.
Lets use _less_ to review the Broker log.

```
less /root/apache-druid-24.0.0/log/broker.log
```

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can search for our extension addition using the following and see that the Broker loaded the extension.

```
/druid-s3-extensions
```

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

Use _q_ to exit _less_.

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">

As processes start, the main thread reports the configuration it has applied as INFO-level messages.
Let’s open the historical log so we can see the S3 configurations.

```
less /root/apache-druid-24.0.0/log/historical.log
```

<h2 style="color:cyan">Step 14</h2><hr style="color:cyan;background-color:cyan;height:5px">

Search for _druid.s3._.

```
/druid\.s3\.
```

<h2 style="color:cyan">Step 15</h2><hr style="color:cyan;background-color:cyan;height:5px">

Use _q_ to exit _less_.

<h2 style="color:cyan">Step 16</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now that Druid is running with the updated configuration, let's perform an ingestion.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
sleep 3
while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
  | jq .multiStageQuery.payload.status.status 2> /dev/null \
  | grep 'SUCCESS\|FAILED' | wc -w) -eq 0 ]; \
  do
    echo "Waiting for ingestion to complete..."
    sleep 3
  done
echo "Ingestion completing"
sleep 5
curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports \
  | jq .multiStageQuery.payload.status.status
```

<h2 style="color:cyan">Step 17</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's look briefly at the Middle Manager log.

```
less /root/apache-druid-24.0.0/log/middleManager.log
```

<h2 style="color:cyan">Step 18</h2><hr style="color:cyan;background-color:cyan;height:5px">

When we search this log for (from the end of the log) _s3_, we see evidence of the Middle Manager pushing logs to deep storage.

```
G?s3
```

<h2 style="color:cyan">Step 19</h2><hr style="color:cyan;background-color:cyan;height:5px">

Use _q_ to exit less.

<h2 style="color:cyan">Step 20</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's take a look at the object store hierarchy.

```
mc tree local
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>These configuration changes only affect the task logs.
Druid still stores the process logs as in previous labs.</i></p>
<hr style="background-color:cyan">


<h2 style="color:cyan">Step 21</h2><hr style="color:cyan;background-color:cyan;height:5px">

With task logs migrating, we may not know exactly where find them.
But, we can always view the task logs using the same API we used in previous labs.

```
WORKER_TASK_ID=$(curl http://localhost:8081/druid/indexer/v1/tasks 2>/dev/null | jq .[0].id | tr -d '"')
curl http://localhost:8081/druid/indexer/v1/task/$WORKER_TASK_ID/log \
  | less
```


<h2 style="color:cyan">Alright! We configured Druid to store task logs in our object store!</h2>


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
