---
slug: having-clause
id: lc2xvs3kgyhr
type: challenge
title: HAVING Clause
teaser: Use the HAVING clause
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

As we have previously seen, the WHERE clause lets us filter using column values.
But, when we aggregate rows into groups, we may want to filter on aggregated values.
This is where the _HAVING_ clause comes in to play.
Read more about the _HAVING_ clause <a href="https://druid.apache.org/docs/latest/querying/sql.html#having" target="_blank">here</a>.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>The HAVING clause filters only on aggregated values or grouping values.
Therefore, the HAVING clause may only be used when the GROUP BY clause is also employed.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Suppose we are interested in looking at those time and language groupings with counts greater than one.
We can use the _HAVING_ clause as shown in the following query.
Click on the _Query_ tab within the _Druid Console_.
Then, copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') AS "time",
  v AS "language",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
HAVING "count" > 1
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can also filter on non-aggregated values as long as they are grouping columns.
In this example, these non-aggregated grouping columns include the _time_ column and the _language_ column.
The following query is an example of filtering on the _language_ column.
Copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') AS "time",
  v AS "language",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
HAVING "language" = 'Arabic'
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, we can combine aggregated and grouping columns in the _HAVING_ clause as shown in the following query.
Copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') AS "time",
  v AS "language",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1, 2
HAVING "language" = 'Arabic'
  AND "count" > 20
```

<h2 style="color:cyan">Nice! We see how to filter groups using the <i>HAVING</i> clause!</h2>


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
