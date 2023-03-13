---
slug: api-simple-query
id: xa04w6w7twoe
type: challenge
title: Druid SQL API Simple Query
teaser: Let's issue a simple SQL query using the API
notes:
- type: text
  contents: Please be patient while we prepare the lab
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

In this exercise we'll see how to use the Druid SQL API for a simple query.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by ingesting the Wikipedia dataset.
We will use _curl_ to post an ingestion query to the Druid MSQ SQL API.
Use the following command to inspect the ingestion query.

```
cat /root/ingestion.json
```

This is a little hard to read, but we see that we post queries using a JSON object.
Read more about SQL ingestion (using MSQ) <a href="https://druid.apache.org/docs/latest/multi-stage-query/concepts.html" target="_blank">here</a>.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Copy, paste and execute the following command to perform the ingestion.


```
curl -X POST \
  -H'Content-Type: application/json'   \
  -d @/root/ingestion.json \
  http://localhost:8888/druid/v2/sql/task
```

<details>
  <summary style="color:cyan"><b>What are the parameters to the curl command?</b></summary>
<hr style="background-color:cyan">
<ul>
<li><i>-X POST</i> - indicates using the HTTP POST operation</li>
<li><i>-H'Content-Type: application/json'</i> - indicates that the payload body is formatted as JSON</li>
<li><i>-d @/root/ingestion.json</i> - specifies the file containing the payload body</li>
<li><i>http://localhost:8888/druid/v2/sql/task</i> - is the target URL for the command</li>
</ul>
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Wait for the ingestion to complete.

Read more about this API <a href="https://druid.apache.org/docs/latest/operations/api-reference.html#datasource-information" target="_blank">here</a>.

```
while [ $(curl -X GET http://localhost:8888/druid/v2/datasources 2> /dev/null | grep wikipedia | wc -w) -eq 0 ]
  do
  printf "."
  sleep 3
  done
printf "\n"
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, issue a simple query.
Copy, paste and execute the following.

```
curl -X POST \
  -H'Content-Type: application/json'   \
  -d '{"query": "SELECT __time, user, added, deleted, delta FROM wikipedia LIMIT 3"}' \
  http://localhost:8888/druid/v2/sql \
  | jq
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>We submit synchronous queries to the <code>/druid/v2/sql</code> endpoint.
But, we can perform asynchronous ingestion queries using the MSQ endpoint <code>/druid/v2/sql/task</code>.
Technically, we could perform asynchronous non-ingestion queries using the MSQ endpoint, but currently this works better for longer running queries.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Great! We have issued a simple query using the Druid SQL API!</h2>


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
