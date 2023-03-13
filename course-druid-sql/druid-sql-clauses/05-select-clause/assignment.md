---
slug: select-clause
id: elxifog9rdvu
type: challenge
title: SELECT Clause
teaser: Use the SELECT clause
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

It may be a bit counterintuitive that SQL does not evaluate the _SELECT_ clause until after evaluating _FROM_, _WHERE_, _GROUP BY_, and _HAVING_ clauses.
In this exercise we'll look at the various capabilities of the _SELECT_ clause.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start with a very vanilla _SELECT_ statement that merely retrieves all the columns.
Click on the _Query_ tab within the _Druid Console_.
Then, copy, paste and execute the following query.


```
SELECT * from wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
```

<details>
  <summary style="color:cyan"><b>We know that all records within the table datasource fall within the time range of these queries. So, why are we using a time range in the queries?</b></summary>
<hr style="background-color:cyan">
Druid queries that do not employ a time range can be very expensive.
In these labs we want to model best practices, so even though all rows of the table fall within the specified time range, we use a time range to reinforce it as a habit.
<hr style="background-color:cyan">
</details>

From this query you can see all the columns in the _wikipedia_ table datasource.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

If we don't want all the columns, we can specify only those columns we _do_ want using the _SELECT_ clause.
This query only retrieves the <i>__time</i>, _countryName_, and _cityName_ columns.
Copy, paste and execute the following query.

```
SELECT __time, countryName, cityName from wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

As we have seen in other queries throughout this lab, we can use functions in the _SELECT_ clause.
This query determines how many total rows there are in the table.
Copy, paste and execute the following query.

```
SELECT count(*) from wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
````

We see there are 6,670 rows in the time range.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can eliminate duplicate results by using the _DISTINCT_ operator.
The following query returns the distinct values of the _countryName_ column.
Copy, paste and execute the following query.

```
SELECT DISTINCT countryName from wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
```

<details>
  <summary style="color:cyan"><b>I see in the Druid SQL docs that there is an <i>ALL</i> keyword. What does that do?</b></summary>
<hr style="background-color:cyan">
Basically, we can use either <i>ALL</i> or <i>DISTINCT</i>.
<i>ALL</i> is the default, which essentially only means "not distinct".
So, if we don't specify either <i>ALL</i> nor <i>DISTINCT</i> we get the default behavior, which is <i>ALL</i>.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

As we have previously seen, we can use _COUNT(*)_ to count the number of rows in a group.
The following query determines the number of rows for each language group.
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

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

When the cardinality is relatively low (e.g., the number of languages) counting works well.
But, when the cardinality becomes high, counting may require significant processing resources.
We can reduce the processing load for counting high cardinality column values by using data sketches.

<details>
  <summary style="color:cyan"><b>What is a data sketch?</b></summary>
<hr style="background-color:cyan">
Data sketches are statistical mechanisms that we can use to get approximate values (within an known error band).
Data sketches reduce processing and also allow the processing to be more uniformly distributed, so queries can be faster.
<br><br>
We can even speed up queries more by using sketches during ingestion, which we will cover in the Druid SQL ingestion labs.
Read more about data sketches <a href="https://datasketches.apache.org/" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

For example, to get an approximate count of the number of languages, we could use a Theta sketch.
The following query allows us to compare an approximate cardinality count (which is much faster for higher cardinalities) with an exact cardinality count.
Copy, paste and execute the following query.

```
SELECT THETA_SKETCH_ESTIMATE(
    DS_THETA(channel)
  ) AS "approximate count",
  COUNT(DISTINCT channel) AS "exact count"
FROM wikipedia
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
```

We see the approximation gives us the same cardinality value as the exact count in this case.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can use quantile sketches to get a sense of the distribution of values.
The following query shows us the quantiles for the _delta_ column.
Copy, paste and execute the following query.

```
SELECT DS_GET_QUANTILES(
    DS_QUANTILES_SKETCH(delta), .25, .5, .75, 1.0
  ) AS "quantiles"
FROM wikipedia
```

We see the list of values that occur at the quartiles.


Read about all the Druid SQL sketch functions <a href="https://druid.apache.org/docs/latest/querying/sql-aggregations.html#sketch-functions" target="_blank">here</a>.


<h2 style="color:cyan">Got it! We see how to project desired columns using the <i>SELECT</i> clause!</h2>


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
