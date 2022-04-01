---
slug: 01-console-sql
id: plmjeigovzua
type: challenge
title: Druid Queries Using the Console
teaser: Use the console to query Druid
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/2stkf5wga0
tabs:
- title: Console
  type: service
  hostname: single-server
  path: /
  port: 8888
  new_window: true
difficulty: basic
timelimit: 900
---

In this challenge we'll query the example Wikipedia data using the Druid Console.
We have already ingested the data for you, so let's do a query!

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the link to open the console (which will open a new browser tab), then click on the query tab.
When you're done, return to this browser tab to continue.

![Open the query tab](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/ClickConsoleQuery.png)

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Copy the following query, paste it in the query window and click the _Run_ button.

<details>
  <summary style="color:cyan"><b>What does this query do?</b></summary>
<hr style="background-color:cyan">
<br>
This query retrieves only certain columns (<i>__time</i>, <i>user</i>, <i>page</i>, <i>added</i>, <i>deleted</i>) for a single day (June 27, 2016).
We use this query to show who was changing which Wikipedia pages on June 27, 2016.
<br><br>
It turns out that the only data we have in the table data source is from June 27, 2016, but we filter on the <i>__time</i> column to demonstrate best practices.
<hr style="background-color:cyan">
</details>


```
SELECT __time, user, page, added, deleted
  FROM wikipedia
  WHERE (TIMESTAMP '2016-06-27' <= __time AND __time < TIMESTAMP '2016-06-28')
```

![Run first query](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/RunFirstQuery.png)


<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>It is a Druid best-practice always to filter by __time.
Not doing so runs the risk of overwhelming the cluster for large table data sources.</i></p>
<hr style="background-color:cyan">

You may have noticed that you only see about one hundred resulting rows from the query.
This is because of the _Auto limit_ feature.

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Turn _Auto limit_ off by clicking on it, and rerun the query to see all the results.

![Turn off Auto limit](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/TurnOffAutoLimit.png)


The Console helps you build queries.
Let's modify the query using the helpful Console features.

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the data source name (i.e., wikipedia), then click on the first option.

![Build Query](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/BuildQuery.png)

You see that the Console populates the list of selected columns with all the columns in the data source, and executes the query.

<br>
<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's pare-down the list of columns to the ones we had before (<i>__time</i>, <i>user</i>, <i>page</i>, <i>added</i>, <i>deleted</i>).

```
SELECT
  __time,
  "user",
  page,
  added,
  deleted
FROM wikipedia
WHERE (TIMESTAMP '2016-06-27' <= __time AND __time < TIMESTAMP '2016-06-28')
```

After you have adjusted the list of columns, add a filter to only look at a single _user_.

<br>
<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click to expand the list under _wikipedia_.
Then, click on _user_, hover over the _Filter_ option and click on _"user"='...'_.

![Add user filter](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/AddUserFilter.png)

<br>
<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Fill in the user value with the following and run the query.

```
Diannaa
```

![Fill in Diannaa](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/FillInDiannaa.png)

Let's look at one more feature of the Druid Console.

<br>
<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the elipses next to the _Run_ button.
Then click on _Explain SQL query_.

![Explain Query](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/ExplainQuery.png)

You will see a pop-up window containing JSON.

![Explain JSON](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-query/ExplainJSON.png)

This JSON is a _native query_.
We will not cover the details of native queries in this track, other than to make you aware of them.

Feel free to explore the Druid Console _Query_ tab by creating your own queries.
You will notice that the Druid Console helps you create filters, and also gives you command completion prompts.

If you want more info on Druid queries using the console, check out this [tutorial](https://druid.apache.org/docs/latest/tutorials/tutorial-query.html).

<br>
<h2 style="color:cyan">Wow! Console queries are easy!</h2>