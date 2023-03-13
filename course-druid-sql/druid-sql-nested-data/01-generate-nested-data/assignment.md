---
slug: generate-nested-data
id: vjtg7uhtr91v
type: challenge
title: Generate Nested Data
teaser: Let's use the Druid Data Generator to create some nested JSON data for later
  exercises
notes:
- type: text
  contents: Please be patient while we prepare the lab
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
difficulty: basic
timelimit: 600
---

In this exercise, we will create some example nested data that we will use throughout the lab.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

SQL Ingestion became available in Druid with the 24.0 release.

Let's download the open source Druid data generator program.

<details>
  <summary style="color:cyan"><b>Want to know more about the data generator?</b></summary>
<hr style="background-color:cyan">
The data generator is a Python program that resides in a GitHub repo within the <i>driver-code</i> directory.
Also, in this directory you find documentation explaining how to use the program as well as several example configuration files.
<br><br>
In this lab, we show you how to download the repo in case you want to use the data generator for your own demo.
<hr style="background-color:cyan">
</details>


```
git clone https://github.com/implydata/druid-datagenerator.git
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's run the data driver to create a batch of 100 records of clickstream data.

```
python3 /root/druid-datagenerator/DruidDataDriver.py \
  -n 100 \
  -f /root/nested_data_config.json \
  -s \
  | sed 's/__time/timestamp/g' \
  > /root/nested_data.json
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

We can investigate the format of the records by looking at the first three records from the file.

```
 head -n 3 /root/nested_data.json | jq
```

<h2 style="color:cyan">Great! We have an example nested data file!</h2>


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
