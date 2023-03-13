---
slug: group-by-clause
id: 9pbqegphfqvg
type: challenge
title: GROUP BY Clause
teaser: Use the GROUP BY clause
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
Once we have gathered the initial rows using the FROM clause, and have filtered those rows using the WHERE clause, we can apply the GROUP BY clause to combine or aggregate rows.
Read more about the _GROUP BY_ clause <a href="https://druid.apache.org/docs/latest/querying/sql.html#group-by" target="_blank">here</a>.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's perform a simple query that groups rows from the _wikipedia_ table datasource by their language.
In the _Druid Console_'s _Query_ tab, copy, paste and run the following query.

```
SELECT v AS "language"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY v
```

<details>
  <summary style="color:cyan"><b>Want to know more about this query? Click here.</b></summary>
<hr style="background-color:cyan">
This query uses JOIN to map the <i>channel</i> column to the appropriate language.
Since the only column the query selects is <i>v</i> (or the language column), we end up with a list of all the languages that were used in the <i>wikipedia</i> dataset, which could be fewer than the list of languages in the <i>langs</i> lookup.
<br><br>
The GROUP BY clause combines all rows with the same language into a separate group.
Normally, we would use GROUP BY with some sort of aggregating function as we will see in the next step.
<hr style="background-color:cyan">
</details>


Notice that the results from this query gives us a distinct list of languages used in the _wikipedia_ dataset.
There are other ways to write this query, but we use this form because we will expand this query in later steps.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Perhaps we would like to know how many rows the query has combined into each group.
We can use _COUNT(*)_ to make this happen.
Copy, paste and execute the following query.

```
SELECT v AS "language",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>In this query we used the ordinal position of the column in the GROUP BY clause (e.g., GROUP BY 1).
This position is a one-based index into the columns listed in the SELECT clause.</i>
<hr style="background-color:cyan">

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

The _COUNT(*)_ aggregation function is just one of many aggregation functions we can use when grouping rows.
For example, we can use _SUM()_ to add up the values of a column within a group, or _AVG()_ to average column values within a group.
Read more about aggregation functions <a href="https://druid.apache.org/docs/latest/querying/sql-aggregations.html" target="_blank">here</a>.

Try out this aggregating query.
Copy, paste and execute the following query.

```
SELECT v AS "language",
  AVG(delta) AS "average delta"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Since Druid focuses on time-based data, we often want to group Druid data into time intervals.
We can do this using the <i>TIME_FLOOR()</i> function as part of the _SELECT_ clause (we will cover the _SELECT_ clause in more detail later).
Read more about time functions <a href="https://druid.apache.org/docs/latest/querying/sql-scalar.html#date-and-time-functions" target="_blank">here</a>.
The following query determines the number of changes to Wikipedia during each 15 minute time interval.
Copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT15m') AS "time",
  COUNT(*) AS "count"
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY 1
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Of course we can combine time-based grouping with other grouping criteria.
The following query groups by one hour intervals and language to determine the number of changes made to Wikipedia each hour for each language.
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
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Suppose we want to explore various permutations of groupings.
For example, we may want to look at grouping by time, and then also by language.
We can do this more efficiently in a single query using _GROUPING SETS_.
Read more about _GROUPING SETS_ <a href="https://learnsql.com/blog/sql-grouping-sets-clause/" target="_blank">here</a>.
Copy, paste and execute the following query.

```
SELECT TIME_FLOOR(__time, 'PT1H') AS "time",
  v AS "language",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY GROUPING SETS (TIME_FLOOR(__time, 'PT1H'), v)
```

In the results, the first four rows are the time grouping.
The remainder of the rows are the language grouping.

<details>
  <summary style="color:cyan"><b>What are the <i>null</i> values in the results?</b></summary>
<hr style="background-color:cyan">
When using <i>GROUPING SETS</i>, if the grouping set does not include the column, then SQL fills the columns values with <i>null</i>.
This makes it a little easier to determine where one set leaves off and the next starts.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Another way to see groupings is using _ROLLUP_.
_ROLLUP_ creates combinations of groupings.
The following query first groups by language and time, followed by groupings of just language, and finally a single line that is the total for all times and languages.
Again, to read more about _ROLLUP_, check out the _SQL ROLLUP Example_ section <a href="https://learnsql.com/blog/sql-grouping-sets-clause/" target="_blank">here</a>.
Copy, paste and execute the following query.

```
SELECT v AS "language",
  TIME_FLOOR(__time, 'PT1H') AS "time",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY ROLLUP (v, TIME_FLOOR(__time, 'PT1H'))
```

The previous query creates many pages of results, so we need to page through the results (not just scroll through them) to see the groupings.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

The _CUBE_ operator creates all group combinations of the specified columns.
In the following query, we use the previous query but replace _ROLLUP_ with _CUBE_.
To read more about _CUBE_, check out the _SQL CUBE Example_ section <a href="https://learnsql.com/blog/sql-grouping-sets-clause/" target="_blank">here</a>.
Copy, paste and execute the following query.

```
SELECT v AS "language",
  TIME_FLOOR(__time, 'PT1H') AS "time",
  COUNT(*) AS "count"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
GROUP BY CUBE (v, TIME_FLOOR(__time, 'PT1H'))
```

If we page through the results, we will see that the results look just like the _ROLLUP_ results except for the last page.
On the last page, we see one additional grouping, which is groupings by time only.


<h2 style="color:cyan">Wow! We see how to use the <i>GROUP BY</i> clause to combine rows into groups!</h2>


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
