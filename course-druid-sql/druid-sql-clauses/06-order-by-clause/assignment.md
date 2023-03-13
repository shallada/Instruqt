---
slug: order-by-clause
id: 6xnse3yltunu
type: challenge
title: ORDER BY Clause
teaser: Use the ORDER BY clause
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

In the previous query clauses, we have filtered and aggregated data to the point where we are ready to retrieve the results.
But, sometimes the order of those results may matter.
For these situations, we can use the _ORDER BY_ clause.
Read more about the _ORDER BY_ clause <a href="https://druid.apache.org/docs/latest/querying/sql.html#order-by" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Consider the following query from a previous exercise.
This query groups by time intervals and language, and counts the number of rows per group.
Click on the _Query_ tab within the _Druid Console_.
Then, copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') as "time",
  v as "language",
  COUNT(*) as "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
```

Notice that the results are ordered by time and then language.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can change the order of the results so that _language_ is the first ordering criteria, followed by <i>__time</i> as in the following query.
Copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') as "time",
  v as "language",
  COUNT(*) as "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
ORDER BY 2, 1
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>While in general purpose SQL we can order on any column, in the Druid dialect of SQL, we can order by any column in an aggregated query, but non-aggregated queries may only order by __time.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can also order by the aggregated value as shown in the following query.
Copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') as "time",
  v as "language",
  COUNT(*) as "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
ORDER BY 3
```


<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

The _ORDER BY_ clause has two modifiers: _ASC_ (ascending) and _DESC_ (descending).
The default is _ASC_ as seen in the previous query.


Let's see an example of _ORDER BY DESC_ by rerunning the previous query with the _DESC_ modifier.

```
SELECT TIME_FLOOR(__time, 'PT1H') as "time",
  v as "language",
  COUNT(*) as "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
ORDER BY 3 DESC
```


<h2 style="color:cyan">Woot! Sorting results is easy with the <i>ORDER BY</i> clause!</h2>


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
