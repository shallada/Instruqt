---
slug: run-ingestion
id: ox8asvbusupj
type: challenge
title: Run the Ingestion
teaser: You've built the ingestion spec - now, run it!
notes:
- type: video
  url: ../assets/06-splash.mp4
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
Now that the ingestion spec is ready, let's ingest some data!

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Here's the command to submit the ingestion spec to Druid.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
```

To show that the ingestion was successful, let's perform a simple query to see how many rows our table has.
This is the query: <i>SELECT COUNT(*) AS numRows FROM wikipedia</i>.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

To execute the query, paste the following into the terminal.

```
curl -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query-number-of-rows.json \
  http://localhost:8888/druid/v2/sql | jq
```

<details>
  <summary style="color:cyan"><b>Want us to explain the output? Click here.</b></summary>
<hr style="background-color:cyan">
The format of the results from the query are a JSON record with a single field: <i>numRows</i>.
This field tells you how many total rows are in the wikipedia table.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Compare the number of rows in the table to the number of rows in the input file.

```
wc -l /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json
```

<details>
  <summary style="color:cyan"><b>Want to understand this output? Click here.</b></summary>
<hr style="background-color:cyan">
The <i>wc -l</i> command counts the number of lines in the raw data input file we ingested.
So, the output shows how many lines (or records) we ingested, followed by the name of the file.
<hr style="background-color:cyan">
</details>


We see that there are fewer rows in the table than records in the input file!
This is because ingestion has rolled-up some of the input rows.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

To investigate this further, look at these records from the input file that are for activity of a given user (Diannaa) for a single specific hour.

```
grep Diannaa \
  /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json | \
  grep "2015-09-12T20:" | \
  jq '"****************","user: "+.user,"added: "+(.added|tostring),"deleted: "+(.deleted|tostring),"delta: "+(.delta|tostring)'
```

<details>
  <summary style="color:cyan"><b>Want to understand this output? Click here.</b></summary>
<hr style="background-color:cyan">
The <i>grep</i> command searches the raw data input file lines containing <i>Diannaa</i>.
Then, we pipe the output from that command into a second <i>grep</i> command that searches for records with a specific timestamp.
The <i>jq</i> command formats the output from the previous command so it's easy to read.
<br><br>
What you end up with is two JSON records where the <i>user</i> is <i>Diannaa</i> and the time is <i>2015-09-12T20</i>.
The records show the user who changed Wikipedia and the number of lines they, added, deleted and total number of lines changed.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Compare those records to the rolled-up row from the table
(here's the query we wil perform: <i>SELECT * FROM wikipedia WHERE user LIKE '%Diannaa%' AND __time BETWEEN TIMESTAMP '2015-09-12 20:00:00' AND TIMESTAMP '2015-09-13 20:00:00'</i>).

```
curl -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query-diannaa.json http://localhost:8888/druid/v2/sql | jq
```

<details>
  <summary style="color:cyan"><b>Want to understand this output? Click here.</b></summary>
<hr style="background-color:cyan">
The <i>curl<i> command issues a query to the Druid <i>wikipedia</i> table.
What you see is one JSON record that is the result of the query.
This is interesting, because we ingested two records, but we only have one in the table.
But if you inspect the one record, you see that its values are a rollup of the two raw records.
<br><br>
Note that the record contains the same user field, and the aggregated added, deleted and delta fields, as well as a record sum field, which tells how many records were rolled up into this row.
<hr style="background-color:cyan">
</details>


You can see that the values (_added_, _deleted_ and _delta_) from the two input records add up to the rolled-up values (_addedSum_, _deletedSum_ and _deltaSum_).


Finally, let's look at the _count_ column named _recordSum_, which tells how many raw data records were rolled-up into a single table data source row.
We will only look at rows where multiple records were rolled up and we will limit the results to 10 rows so the output isn't overwhelming.

Here's the query:

<pre><code style="color:green">SELECT user, recordSum
  FROM wikipedia
  WHERE recordSum > 1
  AND __time BETWEEN
      TIMESTAMP '2015-09-12 20:00:00'
    AND
      TIMESTAMP '2015-09-13 20:00:00'
  LIMIT 10"
</code></pre>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Use this command to execute the query.

```
curl -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query-rollup.json http://localhost:8888/druid/v2/sql | jq
```

<details>
  <summary style="color:cyan"><b>Want to understand this output? Click here.</b></summary>
<hr style="background-color:cyan">
The output is an array of JSON records.
Each record contains a <i>user</i> attribute, and a <i>recordSum</i> attribute.
The <i>recordSum</i> tells how many raw data records were rolled up into the row.
<hr style="background-color:cyan">
</details>

Rollup is great because you can use it to make your queries faster!

<h2 style="color:cyan">Amazing! You were able to create and execute a Druid ingestion!</h2>
