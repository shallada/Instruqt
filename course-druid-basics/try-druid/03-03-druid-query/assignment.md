---
slug: 03-druid-query
id: wxactzhlxcgr
type: challenge
title: Let's Query Druid
teaser: Learn how to query Druid data
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/oi9ikupcmc
tabs:
- title: Console
  type: service
  hostname: container
  path: /
  port: 8888
  new_window: true
difficulty: basic
timelimit: 700
---
With Druid running and data ingested, let's return to the Druid console.

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the browser tab containing the Druid Unified Console, or on the green _Open external window_ button in the middle of the adjacent window as shown.

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>During this challenge, you will need to switch back and forth between the Console tab and this challenge tab.</i></p>
<hr style="background-color:cyan">

![Click console](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/ClickConsole.png)

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

This data is about updates to Wikipedia during a one day period.
Both people and robots contributed to the updates.


Suppose you want to know how updates vary for humans and robots over time.
Here's a query that can help you answer that question.

```
SELECT
  DATE_TRUNC('hour',"__time"),
  (AVG(commentLength) FILTER(WHERE isRobot=true)) as robots,
  (AVG(commentLength) FILTER(WHERE isRobot=false)) as humans
FROM wikipedia
GROUP BY 1
```

Click on the _Query_ tab, paste the query in the console and run it as shown.
Then, check out the results.

![Query Druid](https://raw.githubusercontent.com/shallada/InstruqtImages/main/try-it-out/DruidQuery.png)


<h2 style="color:cyan">Wow! Druid queries are easy!</h2>