---
slug: msq-apis
id: mkifbxnvaylb
type: challenge
title: Use the SQL-based ingestion APIs
teaser: Perform ingestions using SQL-based ingestion APIs
notes:
- type: video
  url: ../assets/05-MSQAPIs.mp4
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

We can use the Multi-Stage Query framework APIs to perform ingestions (and longer running queries) by posting JSON to the API endpoint.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Review the ingestion JSON file.

```
cat /root/ingestion.json | jq
```

<details>
  <summary style="color:cyan"><b>What is the <i>context</i> object?</b></summary>
<hr style="background-color:cyan">
The <i>context</i> object gives Druid special instructions for how to perform various activities during the operation.
These activities may vary depending on if the operation is a query or an ingestion.
<br><br>
For example, aggregations using sketches during queries should return the resulting number.
But during ingestion, aggregations using sketches should retain the results as a sketch, which will result in eventually faster queries.
<br><br>
Operations using the API can control context parameter values using the <i>context</i> object.
Operations performed using the Druid Console can specify context parameter values using SQL comments (e.g., <i>--:context groupByEnableMultiValueUnnesting: false</i>).
Read more <a href="https://druid.apache.org/docs/latest/querying/sql-query-context.html" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start the ingestion by posting the file as follows.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json | jq -r '.taskId')
```
<details>
  <summary style="color:cyan"><b>What does it mean to "start the ingestion"?</b></summary>
<hr style="background-color:cyan">
These API operations can be long running.
Therefore, they are asynchronous.
So the <i>curl</i> command above merely launches the ingestion.
<br><br>
The returned result of starting the ingestion is a report that contains the operation ID.
You see in the above command that we use <i>jq</i> to parse out the ID, and store it in a shell variable (i.e., <i>TASK_ID</i>).
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Check the status of the ingestion using the following API with the operation ID embedded in the URL.
Note that it may take a few seconds after launching the ingestion before this API will recognize the ID - if this operation returns nothing, wait a few seconds and try it again.


Also, the results will scroll by quickly, but in the next step we'll capture and review the results.

```
curl  -H'Content-Type: application/json' \
     http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports \
     | jq
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Run the command again and pipe the results into a file named _/root/report.json_.

```
curl  -H'Content-Type: application/json' \
     http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports \
     | jq > /root/report.json > report.json
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Investigate the _report.json_ file from the previous step in the editor.

<a href="#img-5">
  <img alt="Check Status" src="../assets/CheckStatus.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Check Status" src="../assets/CheckStatus.png" />
</a>

We can investigate the resulting report to determine the state of the ingestion (e.g., _RUNNING_, _SUCCESS_, or _FAIL_).

<h2 style="color:cyan">Wow! Using the SQL-based ingestion APIs is easy!</h2>


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
