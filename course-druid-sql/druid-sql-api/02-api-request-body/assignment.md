---
slug: api-request-body
id: uflnhdg4jzvp
type: challenge
title: Druid SQL API Request Body
teaser: Investigate the API request body parameters
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

In the previous exercise we performed a simple query by posting a JSON object to the SQL API.
In this exercise, we'll look at some parameters we can set within the JSON query object.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

The first parameter we will explore is _resultFormat_.
This parameter can affect the format of the query results.
The default format is a JSON object as we saw in the previous exercise.
Let's set the format to output CSV results.


Copy, paste and execute the following.

```
curl -X POST \
  -H'Content-Type: application/json'   \
  -d '{"query": "SELECT __time, user, added, deleted, delta FROM wikipedia LIMIT 3", "resultFormat": "csv"}' \
  http://localhost:8888/druid/v2/sql
```

We see the results are in CSV format.
Read more about formatting results <a href="https://druid.apache.org/docs/latest/querying/sql-api.html#result-formats" target="_blank">here</a>.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's add another query parameter that causes the results to include a header row.
The name of this parameter is _header_ and its default value is _false_.
We'll set this to _true_.


Copy, paste and execute the following.

```
curl -X POST \
  -H'Content-Type: application/json'   \
  -d '{"query": "SELECT __time, user, added, deleted, delta FROM wikipedia LIMIT 3", "resultFormat": "csv", "header": true}' \
  http://localhost:8888/druid/v2/sql
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, we can parameterize the SQL query using the JSON query object.
In this example, we supply _delta_ values as the query parameters.

Copy, paste and execute the following.

```
curl -X POST \
  -H'Content-Type: application/json'   \
  -d '{"query": "SELECT __time, user, added, deleted, delta FROM wikipedia WHERE delta > ? AND delta < ? LIMIT 3", "resultFormat": "csv", "header": true, "parameters": [{ "type": "INTEGER", "value": 0}, {"type": "INTEGER", "value": 100}]}' \
  http://localhost:8888/druid/v2/sql
```

There are a few other request body parameters.
Read more about these parameters <a href="https://druid.apache.org/docs/latest/querying/sql-api.html#request-body" target="_blank">here</a>.


<h2 style="color:cyan">Splendid! We see how to use the JSON query object parameters!</h2>


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
