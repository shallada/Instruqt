---
slug: topn
id: xfckl0n50nat
type: challenge
title: Druid SQL Explain Plan TopN
teaser: Let's see SQL queries that Druid translates into TopN queries
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

TopN queries are fast approximations that work a lot like GroupBy queries.
Read more about GroupBy native queries <a href="https://druid.apache.org/docs/latest/querying/topnquery.html" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

To create a TopN native query, we need to aggregate rows, order and limit the results.
In this example, we'll _GROUP BY_ channel, order by _COUNT(*)_ as follows, and _LIMIT_ the number of results to 100.

```
SELECT channel, COUNT(*)
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2016-06-27 00:00:00'
  AND TIMESTAMP '2016-06-28 00:00:00'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 100
```

Copy, paste and execute the following command to create the associated TopN plan.

```
curl -X POST   -H'Content-Type: application/json' \
  -d '{"query": "EXPLAIN PLAN FOR SELECT channel, COUNT(*) FROM wikipedia WHERE __time BETWEEN TIMESTAMP '"'"'2016-06-27 00:00:00'"'"' AND TIMESTAMP '"'"'2016-06-28 00:00:00'"'"' GROUP BY 1 ORDER BY 2 DESC LIMIT 100"}' \
  http://localhost:8888/druid/v2/sql \
  | jq -r '.[0].PLAN' \
  | jq -r '.[0]' \
  > topn_plan.json
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's open the resulting plan file (named <i>topn_plan.json</i>) in the editor.

<a href="#img-2">
  <img alt="Open TopN" src="../assets/OpenTopN.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Open TopN" src="../assets/OpenTopN.png" />
</a>

Besides the _queryType field, notice the addition of the _threshold_ field.


This concludes the tour of the four native query types that Druid targets with its SQL translation!


<h2 style="color:cyan">Excellent! We have reviewed a TopN native query type!</h2>


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
