---
slug: data-cube
id: nvux7kdnxdhf
type: challenge
title: Create a Data Cube
teaser: Once you have migrated your data, view it using Polaris data cubes!
notes:
- type: video
  url: ../assets/03-data-cube.mp4
tabs:
- title: Shell
  type: terminal
  hostname: single-server
difficulty: basic
timelimit: 600
---

In other challenges, we have migrated data to Polaris.
In this challenge, we'll use data cubes to visualize the data.

<details>
  <summary style="color:cyan"><b>What is a data cube? Click here.</b></summary>
<hr style="color:cyan">
A data cube is a way to interactively visualize your data with various types of tables and charts.
Data cubes use the data from one or more tables, or even an SQL statement.
You can quickly create graphs to visualize the interesting dimensions of your data.
Learn more <a href="https://docs.imply.io/polaris/managing-data-cubes/" target="_blank">here</a>.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Open a browser tab to Polaris by executing the following command and then clicking on the resulting link.

```
echo https://$ORGANIZATION_NAME.app.imply.io/
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the Polaris tab, create a data cube by following these instructions.

<a href="#img-2">
  <img alt="Create Data Cube" src="../assets/CreateDataCube.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="Create Data Cube" src="../assets/CreateDataCube.png" />
</a>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the data cube.

<a href="#img-3">
  <img alt="Save Data Cube" src="../assets/SaveDataCube.png" />
</a>

<a href="#" class="lightbox" id="img-3">
  <img alt="Save Data Cube" src="../assets/SaveDataCube.png" />
</a>

Once you have successfully Save the data cube, you will see something like the following.

<a href="#img-2">
  <img alt="View Data Cube" src="../assets/ViewDataCube.png" />
</a>

<a href="#" class="lightbox" id="img-2">
  <img alt="View Data Cube" src="../assets/ViewDataCube.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Modify the filter to use the latest hour by clicking as shown.

<details>
  <summary style="color:cyan"><b>What are data cube filters? Click here.</b></summary>
<hr style="color:cyan">
Data cube filters let you limit the data you want to visualize - think of filters as like a <i>WHERE</i> clause.
While the default time filter is the latest day, since we only have a few minutes of data, we want to zoom into the latest hour.
<hr style="color:cyan">
</details>

<a href="#img-4">
  <img alt="Latest Hour" src="../assets/LatestHour.png" />
</a>

<a href="#" class="lightbox" id="img-4">
  <img alt="Latest Hour" src="../assets/LatestHour.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Change what the chart will show from _Number of events_ to _Cpu_ as shown:

<details>
  <summary style="color:cyan"><b>What is the difference between showing dimensions and metrics? Click here.</b></summary>
<hr style="color:cyan">
Polaris displays the metrics, highlighted in green, as contents of the graph or chart.
Polaris uses dimensions, highlighted in blue, as classifications or axes to frame the graph or chart.
So, the line you want to plot, or the bars you want to see are metrics.
But the domains or axes of the chart are the dimensions.
<hr style="color:cyan">
</details>

<a href="#img-5">
  <img alt="Show CPU" src="../assets/ShowCPU.png" />
</a>

<a href="#" class="lightbox" id="img-5">
  <img alt="Show CPU" src="../assets/ShowCPU.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Add the _Time_ dimension to show.

<a href="#img-6">
  <img alt="Show CPU" src="../assets/ShowTime.png" />
</a>

<a href="#" class="lightbox" id="img-6">
  <img alt="Show CPU" src="../assets/ShowTime.png" />
</a>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Add the _processName_ dimension to show.

<a href="#img-7">
  <img alt="Show ProcesName" src="../assets/ShowProcessName.png" />
</a>

<a href="#" class="lightbox" id="img-7">
  <img alt="Show ProcesName" src="../assets/ShowProcessName.png" />
</a>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Scroll to the section of the table where you see the events by process name.
Note that the table shows both the values and a bar chart (in blue).

<a href="#img-8">
  <img alt="Scroll time" src="../assets/ScrollTime.png" />
</a>

<a href="#" class="lightbox" id="img-8">
  <img alt="Scroll time" src="../assets/ScrollTime.png" />
</a>

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch the view of the data to a _Line Chart_ and investigate the view.

<a href="#img-9">
  <img alt="Switch To Line" src="../assets/SwitchToLine.png" />
</a>

<a href="#" class="lightbox" id="img-9">
  <img alt="Switch To Line" src="../assets/SwitchToLine.png" />
</a>

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

Visualize the data as a bar chart and investigate the view (you may need to scroll to the right to see the data).

<a href="#img-10">
  <img alt="Switch To Bar" src="../assets/SwitchToBar.png" />
</a>

<a href="#" class="lightbox" id="img-10">
  <img alt="Switch To Bar" src="../assets/SwitchToBar.png" />
</a>

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, let's create a dashboard from this view so we can share it with others.

<details>
  <summary style="color:cyan"><b>What is a dashboard? Click here.</b></summary>
<hr style="color:cyan">
A dashboard is a combination of coordinated data views.
You create dashboards by pulling views from data cubes.
Learn more <a href="https://docs.imply.io/polaris/dashboards-overview/" target="_blank">here</a>.
<hr style="color:cyan">
</details>

<a href="#img-11">
  <img alt="Create Dashboard" src="../assets/CreateDashboard.png" />
</a>

<a href="#" class="lightbox" id="img-11">
  <img alt="Create Dashboard" src="../assets/CreateDashboard.png" />
</a>

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

Accept the defaults for creating the dashboard.

<a href="#img-12">
  <img alt="Exit Edit Dashboard" src="../assets/ExitEditDashboard.png" />
</a>

<a href="#" class="lightbox" id="img-12">
  <img alt="Exit Edit Dashboard" src="../assets/ExitEditDashboard.png" />
</a>

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">

Give the dashboard a name and click _Create_.

<a href="#img-13">
  <img alt="Finish Dashboard" src="../assets/FinishDashboard.png" />
</a>

<a href="#" class="lightbox" id="img-13">
  <img alt="Finish Dashboard" src="../assets/FinishDashboard.png" />
</a>

<h2 style="color:cyan">Wow! Data Cubes and Dashboards make visualizing data easy!</h2>


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
