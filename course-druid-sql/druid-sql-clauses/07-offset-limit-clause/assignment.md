---
slug: offset-limit-clause
id: ui73bk9ftap3
type: challenge
title: OFFSET and LIMIT Clauses
teaser: Use the OFFSET and LIMIT clauses
notes:
- type: text
  contents: Please be patient while we prepare the lab
tabs:
- title: Druid Console
  type: website
  url: https://container-8443-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
difficulty: basic
timelimit: 600
---

The final clauses in the query evaluation sequence are the _OFFSET_ and _LIMIT_ clauses.
The _OFFSET_ clause lets us skip a specified number of rows in the results, and the _LIMIT_ clause gives us a specified number of rows from the results.
We can use these clauses to retrieve the top-N results, and also for paging through larger results sets.
Read more about <a href="https://druid.apache.org/docs/latest/querying/sql.html#offset" target="_blank"><i>OFFSET</i> here</a> and <a href="https://druid.apache.org/docs/latest/querying/sql.html#limit" target="_blank"><i>LIMIT</i> here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by creating a query to see only the top three delta values from the _wikipedia_ table datasource.
Click on the _Query_ tab within the _Druid Console_.
Then, copy, paste and execute the following query.

```
SELECT __time, delta
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
ORDER BY 2 DESC
LIMIT 3
```

We see only the three results.
Since we combined the _LIMIT_ clause with the _ORDER BY_ clause, we get the top three _delta_ values.


<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's simulate paging through results, 10 rows at a time.
We can use _OFFSET_ and _LIMIT_ clauses together.


The following query gets the first 10 rows from the results.
Copy, paste and execute the following query.

```
SELECT __time, delta
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
ORDER BY 2 DESC
LIMIT 10
OFFSET 0
```


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, let's simulate retrieving the second page of results with the following query.
For this query, we still limit the number of rows to 10, but we change the offset to skip the first 10 rows.
Copy, paste and execute the following query.

```
SELECT __time, delta
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
ORDER BY 2 DESC
LIMIT 10
OFFSET 10
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Even though the LIMIT clause appears in front of the OFFSET clause, SQL evaluates the OFFSET clause before the LIMIT clause.</i>
<hr style="background-color:cyan">


It's that simple!

<h2 style="color:cyan">Perfect! We see how to use the <i>OFFSET</i> and <i>LIMIT</i> clauses!</h2>


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
