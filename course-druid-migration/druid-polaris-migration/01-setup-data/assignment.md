---
slug: setup-data
id: os5fyzhcey89
type: challenge
title: Create Druid Data
teaser: Start creating Druid data to migrate to Polaris
notes:
- type: video
  url: ../assets/01-CreateDruidData.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
difficulty: basic
timelimit: 600
---

In this challenge, we will:
- Create some sample data
- Ingest the sample data into a local Druid table
- Query the table to see what the data looks like


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Create some sample data.

<details>
  <summary style="color:cyan"><b>What does this command do? Click here.</b></summary>
<hr style="color:cyan">
We created a bash script (<i>process-monitor-producer.sh</i>) that (using the <i>top</i> command) monitors the Druid processes and prints per process utilizations.
The command redirects the output from the script into a file named <i>raw_data.csv</i>.
<hr style="color:cyan">
</details>

```
/root/process-monitor-producer.sh ISO CSV 100 > /root/raw_data.csv
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Familiarize yourself with the data by inspecting the first ten rows from the file.

```
head -10 /root/raw_data.csv \
   | column -t -s,
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Ingest the sample data into a local Druid table.

<details>
  <summary style="color:cyan"><b>How does this ingestion work? Click here.</b></summary>
<hr style="color:cyan">
This command sends Druid an <i>ingestion specification</i> that tells Druid how to ingest the sample data.
You can look at the ingestion spec by clicking on the <i>Editor</i> tab and opening the file named <i>ingestion-spec.json</i> in the <i>root</i> directory.
If you want to know more about ingestion, check out our course on Druid Ingestion and Data Modeling at <a href="https://learn.imply.io" target="_blank">learn.imply.io</a>.
<hr style="color:cyan">
</details>

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query the number of rows in the Druid table to demonstrate you have ingested rows.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d '{ "query": "SELECT COUNT(*) as \"count\" FROM \"process-data\"" }' \
   http://localhost:8888/druid/v2/sql \
| jq
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query a few rows to see what the data looks like inside the Druid table.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d '{ "query": "SELECT * FROM \"process-data\" LIMIT 3" }' \
   http://localhost:8888/druid/v2/sql \
| jq
```

<h2 style="color:cyan">You're all set! You have a Druid table that we will migrate to Polaris!</h2>
