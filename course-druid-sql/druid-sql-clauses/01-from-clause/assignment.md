---
slug: from-clause
id: ldltc6nuqowb
type: challenge
title: FROM Clause
teaser: Use several forms of the FROM clause
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
Within a query, the FROM clause is the first clause SQL evaluates.

<details>
  <summary style="color:cyan"><b>What does the <i>FROM</i> clause do?</b></summary>
<hr style="background-color:cyan">
The <i>FROM</i> clause gathers the initial data for the query so that the query can filter and organize the data.
In the Druid dialect of SQL, the FROM clause can gather data from a table datasource, a subquery, or a JOIN clause.
Read more <a href="https://druid.apache.org/docs/latest/querying/sql.html#from" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We have installed Druid in this lab environment and have ingested the Wikipedia data into a table datasource named _wikipedia_.

In this first exercise, let's query from the _wikipedia_ table datasource (we will not filter the data just yet).
In the _Druid Console_, click the query tab, paste the following query and run it.

```
SELECT *
FROM wikipedia
```

<a href="#img-1">
  <img alt="Select Star" src="../assets/SelectStar.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Select Star" src="../assets/SelectStar.png" />
</a>

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Normally, Druid queries should have a time filter.
We didn't use a filter in this first example because we are focusing on the FROM clause.
Not using a time filter requires Druid to perform a full scan of all the table's segments.
This is not a problem in this example because our data is small, but we want to avoid unfiltered queries in large or production systems.</i>
<hr style="background-color:cyan">

We see that the _wikipedia_ table datasource has many columns.
Since we didn't use a WHERE clause to filter the rows, our query returns all the rows in the table datasource.
However, the _Druid Console_ limits the results to the first 1,000 rows.

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can use the FROM clause with a subquery.

<details>
  <summary style="color:cyan"><b>What is a subquery?</b></summary>
<hr style="background-color:cyan">
The target of the FROM clause is a set of data.
That set may be a table data source, or it may be a complete query.
When we use a complete query as the set of data within another query, we call it a <i>subquery</i>.
Read more <a href="https://druid.apache.org/docs/latest/querying/datasource.html#query" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

Open a new query tab.
Paste and run the following query.

```
SELECT *
FROM (
  SELECT __time, page, channel
  FROM wikipedia
)
```

<a href="#img-2">
  <img alt="From Subquery" src="../assets/FromSubquery.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="From Subquery" src="../assets/FromSubquery.png" />
</a>

Since the subquery filters the columns with a SELECT clause, our query now only returns the columns available from the subquery.
However, since the subquery does not have a WHERE clause, the outer query still returns all the rows (limited by the _Druid Console_ to the first 1,000 rows).

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, we can use a JOIN operation within our FROM clause as the target of our data set.

<details>
  <summary style="color:cyan"><b>What is a JOIN operation?</b></summary>
<hr style="background-color:cyan">
In SQL, JOINs allow the query to connect two or more tables using values that are common between columns of the separate tables.
The result is like a table dataset with columns from all of the original tables.
Druid SQL supports limited JOIN operations.
With Druid, you can only JOIN between a table datasource and an in-memory datasource such as a <i>lookup</i>.
Lookups are like tables, but they must be small enough to reside in memory.
Read more about lookups <a href="https://druid.apache.org/docs/latest/querying/lookups.html" target="_blank">here</a>.
<br><br>
One other note about Druid JOINs: the ON part of the JOIN clause must only use an equality operator.
Read more about JOINs <a href="https://druid.apache.org/docs/latest/querying/datasource.html#join" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

We can replace the cryptic _channel_ column values from the previous query using a lookup that we have created for you.
In a new query tab, paste and run the following query.

```
SELECT __time,
  page,
  v AS "language"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
```

<a href="#img-3">
  <img alt="Where Join" src="../assets/WhereJoin.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Where Join" src="../assets/WhereJoin.png" />
</a>

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>The above JOIN example is a INNER JOIN, which is the default.
Druid SQL also supports a LEFT OUTER JOIN.
See this <a href="https://www.diffen.com/difference/Inner_Join_vs_Outer_Join" target="_blank">article</a> for an explanation of the various JOIN types.</i>
<hr style="background-color:cyan">

In Druid we can use JOIN operations within the FROM clause to make the results more readable.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

You may be wondering about the lookup used in the previous step.
As a bonus, let's investigate the loopup.
Copy, paste and execute the following query as shown.

```
SELECT *
FROM lookup.langs
```

<a href="#img-4">
  <img alt="Investigate Lookup" src="../assets/InvestigateLookup.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Investigate Lookup" src="../assets/InvestigateLookup.png" />
</a>

We see that the lookup, named _langs_, resides in a separate schema named _lookup_, which we must include as part of the fully qualified datasource name.
The _langs_ lookup consists of two columns: _k_ (key), and _v_ (value).
All lookups will have these same two columns.

<details>
  <summary style="color:cyan"><b>What is a schema?</b></summary>
<hr style="background-color:cyan">
In SQL parlence, a schema is a collection of tables.
Druid clusters usually have a few different schemas:
<ul>
<li>The default schema is named <i>druid</i> and contains standard table datasources.</li>
<li>The <i>lookup</i> schema contains relatively smaller lookup tables, which are key/value mappings.</li>
<li>The <i>sys</i> schema</i> contains virtual metadata tables.</li>
<li>The <i>INFORMATION SCHEMA</i> contains other virtual metadata tables for managing the cluster.</li>
</ul>
Read more <a href="https://druid.apache.org/docs/latest/querying/sql-metadata-tables.html" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


Note that the values in the _k_ column correspond to the values found in the _wikipedia_ table datasource's _channel_ column, which explains how SQL is able to join the two datasources.

<h2 style="color:cyan">Great! We see how to use the <i>FROM</i> clause!</h2>


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
