---
slug: where-clause
id: y4fbeu1auxxk
type: challenge
title: WHERE Clause
teaser: Use the WHERE clause
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
After the FROM clause, SQL evaluates the WHERE clause

<details>
  <summary style="color:cyan"><b>What does the <i>WHERE</i> clause do?</b></summary>
<hr style="background-color:cyan">
The <i>WHERE</i> clause filters rows of the dataset by comparing columns values.
Read more <a href="https://druid.apache.org/docs/latest/querying/sql.html#where" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Nearly all Druid queries should contain a time filter.

<details>
  <summary style="color:cyan"><b>Why do Druid queries require a time filter?</b></summary>
<hr style="background-color:cyan">
Druid stores data within segments based on time intervals.
By specifying a time filter, Druid is able to quickly narrow down which segments to consider for the query.
Without a time filter, Druid would need to scan all segments associated with the table datasource, which would consume a lot of time and resources for large production tables.
Read more <a href="https://druid.apache.org/docs/latest/design/segments.html" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

Let's add a time filter to the query we used in the previous exercise.
Recall that this query retrieves two columns (<i>__time</i> and _page_) from the _wikipedia_ table datasource and joins the _langs_ lookup to get the page's language.
Because the _wikipedia_ table datasource is so small, this filter will not eliminate any rows, but instead merely demonstrates how to apply a time filter.

In the _Druid Console_, click on the _Query_ tab.
Then, copy, paste and execute this query
(In this exercise, feel free to open a new tab for each additional query, or just replace an existing query in an existing tab).

```
SELECT __time,
  page,
  v AS "language"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
  AND TIMESTAMP '2015-09-13 20:00:00'
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Recall that SQL evaluates the WHERE clause after the FROM/JOIN clause, but before the SELECT clause.
Therefore, even though the final result only contains three columns, the WHERE clause may use the other columns for filtering.

Let's also filter out any pages that use the English language.
Copy, paste and execute this query.

```
SELECT __time,
  page,
  v AS "language"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
    AND TIMESTAMP '2015-09-13 20:00:00'
  AND langs.v <> 'English'
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can also use subqueries in the WHERE clause.
Here is another way to write the query from the previous step using a subquery.
Copy, paste and execute this query.

```
SELECT __time,
  page,
  v AS "language"
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
    AND TIMESTAMP '2015-09-13 20:00:00'
  AND langs.v IN (
    SELECT langs.v
    FROM lookup.langs
    WHERE lookup.langs.v <> 'English'
  )
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Data types can impact the effects of the WHERE clause.

Let's add another column, _delta_, to the SELECT clause, and search for all _delta_ greater than 2.

You can learn more about Druid's logical operators <a href="https://druid.apache.org/docs/latest/querying/sql-operators.html#logical-operators" target="_blank">here</a>.

Copy, paste and execute this query.

```
SELECT __time,
  page,
  v AS "language",
  delta
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
    AND TIMESTAMP '2015-09-13 20:00:00'
  AND langs.v <> 'English'
  AND delta > 2
```

Notice the second result in the list with a _delta_ of 18.

<a href="#img-4">
  <img alt="Result Delta 18" src="../assets/ResultDelta18.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Result Delta 18" src="../assets/ResultDelta18.png" />
</a>

This is reasonable since 18 is greater than 2.

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

What happens if we compare a number to a CHAR?
Let's change `delta > 2` to `delta > '2'`.
Copy, paste and execute this query.

```
SELECT __time,
  page,
  v AS "language",
  delta
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
    AND TIMESTAMP '2015-09-13 20:00:00'
  AND langs.v <> 'English'
  AND delta > '2'
```

We still see the results containing _delta_ of 18.
This implies that the _'2'_ is automatically converted to a number.

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's cast the _delta_ value to a CHAR so the query compares CHARs.
Copy, paste and execute this query.

```
SELECT __time,
  page,
  v AS "language",
  delta
FROM wikipedia
  JOIN lookup.langs ON wikipedia.channel = langs.k
WHERE __time BETWEEN TIMESTAMP '2015-09-12 20:00:00'
    AND TIMESTAMP '2015-09-13 20:00:00'
  AND langs.v <> 'English'
  AND CAST(delta AS CHAR) > '2'
```

Now, we see that the results containing _delta_ = 18 are missing!
This is because, from a CHAR perspective, '18' is less that '2', much like 'AB' is less than 'B'.

The moral to the story is that we need to be aware of data types because they can affect the WHERE clause.


<h2 style="color:cyan">Cool! We see how to use the <i>WHERE</i> clause to filter rows!</h2>


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
