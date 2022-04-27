---
slug: batch-migration
id: 5aqusszrztlx
type: challenge
title: Migrate Batch Data to Polaris
teaser: Extract data from the Druid table and ingest it with Polaris
notes:
- type: video
  url: ../assets/04-MigrateBatchData.mp4
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

Now that we have created a Polaris table, let's ingest some data from our local Druid table.

In this challenge we will perform the following:
- Extract data from the local Druid database we set up in the first challenge
- Upload the data to Polaris
- Ingest the uploaded data into a Polaris table

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Extract the data from the Druid table into a local file.

<details>
  <summary style="color:cyan"><b>What does this command do? Click here.</b></summary>
<hr style="background-color:cyan">
We'll use curl to execute a SELECT command for the local Druid table. Notice that this command has no WHERE clause, so it will retrieve all rows from the table. We also use jq to format the output for ingestion by Polaris.<br>
In a large production system, you would not want to extract all data into a single file as that might result in a file that is too large. In this situation, it might be useful to create several batches for ingestion using a WHERE clause and identifying time ranges.<br>
One more useful hint for doing batch ingestion - depending on your environment, you may improve throughput by storing your extraction files on something like S3.
<hr style="background-color:cyan">
</details>

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d "{\"query\":\"SELECT * FROM \\\"process-data\\\"\"}" \
 http://localhost:8888/druid/v2/sql \
| jq  -c .[] > rows.json
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

In preparation for uploading the data to Polaris, compress the extracted data.

```
gzip rows.json
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Upload the compressed data. You can learn more about uploading to Polaris [here](https://docs.imply.io/polaris/api-upload/).

```
curl --location --request POST "https://api.imply.io/v1/files" \
  --header "Authorization: Bearer $IMPLY_TOKEN" \
  --form 'file=@"rows.json.gz"' \
| jq
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Ingest data and store the resulting job ID in a variable.

<details>
  <summary style="color:cyan"><b>How does this command work? Click here.</b></summary>
<hr style="background-color:cyan">
At its foundation, this command is a curl command that uses the table ID as part of the target endpoint URL. The body of the command is JSON describing the ingestion, including the name of the file to ingest and information about how to handle the __time field. Learn more <a href="https://docs.imply.io/polaris/api-ingest/" target="_blank">here</a>.<br>
Note that this command uses jq to parse the results returned by curl and extract the job ID. We store this job ID so we can use it to query the status of the ingestion.<hr style="background-color:cyan">
</details>


```
JOB_ID=$(curl --location --request POST "https://api.imply.io/v1/tables/$TABLE_ID/ingestion/jobs" \
  --header "Authorization: Bearer $IMPLY_TOKEN" \
  --header "Content-Type: application/json" \
  --data-raw '{
      "jobType": "ingestion",
      "fileList": [
          "rows.json.gz"
      ],
      "inputFormat": "json",
      "timestampMapping": {
          "inputField": "__time",
          "format": "iso"
      }
  }' \
| jq -r .jobId)
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Ingestion may take some time. Since we stored job ID of the ingestion, we can use the following command to monitor the progress of the ingestion.
Learn more [here](https://docs.imply.io/polaris/IngestionJobsApi/#get-the-progress-of-an-ingestion-job).


```
curl --location --request GET "https://api.imply.io/v1/tables/$TABLE_ID/ingestion/jobs/$JOB_ID/progress" \
  --header "Authorization: Bearer $IMPLY_TOKEN" \
| jq
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

The following loop uses the previous command to wait until the ingestion is successful.

```
until \
  curl --location --request GET "https://api.imply.io/v1/tables/$TABLE_ID/ingestion/jobs/$JOB_ID/progress"   --header "Authorization: Bearer $IMPLY_TOKEN" \
  | jq -r .jobStatus \
  | grep -m 1 SUCCESS
do
  sleep 10
done
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

We want to perform a query to verify the data was ingested.
We need the project ID to perform a query.
The following command retrieves the project ID.

<details>
  <summary style="color:cyan"><b>What is a Polaris project? Click here.</b></summary>
<hr style="background-color:cyan">
In Polaris, a project refers to the cloud machinery we are using to host our data.
You can modify the project size to scale up or scale down.
Learn more <a href="https://docs.imply.io/polaris/concepts/#project" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

```
export PROJECT_ID=$(curl --location --request GET 'https://api.imply.io/v1/projects' \
  --header "Authorization: Bearer $IMPLY_TOKEN" \
| jq -r .[0].metadata.uid)
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query the first three rows by executing the following command.

```
curl --location --request POST "https://api.imply.io/v1/projects/$PROJECT_ID/query/sql" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $IMPLY_TOKEN" \
  --data-raw "{
      \"query\": \"SELECT * FROM \\\"$TABLE_NAME\\\" LIMIT 3\"
  }" \
| jq
```

<h2 style="color:cyan">Outstanding! You have ingested data into the Polaris table!</h2>
