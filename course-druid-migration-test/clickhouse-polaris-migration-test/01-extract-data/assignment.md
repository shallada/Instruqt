---
slug: extract-data
id: a7tovl3xryoo
type: challenge
title: Extract Data
teaser: Extract data from Clickhouse
notes:
- type: video
  url: ../assets/01-ExtractingClickhouseData.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
difficulty: basic
timelimit: 6000
---

In this lab, we'll see how to extract data from Clickhouse.
We'll follow these steps:
- Download some data
- Use the downloaded data to create a Clickhouse database
- Extract the data from the database

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Download the sample data we have prepared.
```
curl https://koalastothemax.com/logs/kttm-2019-08-19.json.gz --output kttm-2019-08-19.json.gz
gunzip kttm-2019-08-19.json.gz
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Create a Clickhouse database.
```
clickhouse-client --query "CREATE DATABASE IF NOT EXISTS tutorial"
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Create a table.
```
clickhouse-client --queries-file create_kttm.sql
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Start the database client.
```
clickhouse-client
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Run this client command to set a database parameter for interpreting the timestamps.
```
SET date_time_input_format='best_effort'
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Run this client command to add the data to the table.
```
INSERT INTO tutorial.kttm FROM INFILE 'kttm-2019-08-19.json' FORMAT JSONEachRow
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Run this client command to verify the data is in the table
(You can expect more than 200,000 rows).
```
select count(*) from tutorial.kttm
```


<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span> <i>You are now ready to extract data from the database.
The steps you completed up to this point merely created a Clickhouse table with data.</i></p>


<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Run this client command to extract the table data.
```
select * from tutorial.kttm into OUTFILE 'kttm.json' FORMAT JSONEachRow
```

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Run this client command to exit the client.
```
quit
```

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

List out the files in the current directory.
```
ls -al
```

Notice the file named _kttm.json_.
This is the file that contains the extracted data in JSON format.

<h2 style="color:cyan">Step11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Check out the first few rows of the extracted data.
```
head -3 kttm.json | jq
```

<h2 style="color:cyan">Outstanding! Now you have data you can import into Polars!</h2>
