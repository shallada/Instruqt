---
slug: 03-data-schema-dimensions
id: phlawh29apmv
type: challenge
title: Data Schema Dimensions
teaser: Create the dataSchema dimensions for your table
notes:
- type: video
  url: https://fast.wistia.net/embed/iframe/5x5wqt50h8
tabs:
- title: Shell
  type: terminal
  hostname: single-server
- title: Editor
  type: code
  hostname: single-server
  path: /root
difficulty: basic
timelimit: 750
---

The next step in setting up the data schema is to define the dimensions.
[Dimensions](https://druid.apache.org/docs/latest/ingestion/index.html#dimensionsspec) are those columns in your table that contain regular data values.

<br>
<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's take another look at an example record in the input data.

```
head --lines 1 /root/apache-druid-0.21.1/quickstart/tutorial/wikiticker-2015-09-12-sampled.json | jq
```

We'll only use one of these fields (i.e. _user_) as a dimension column so that we can demonstrate rollup.
You may recall that the quickstart example uses all of these fields as dimensions.

<br>
<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the ingestion spec in the editor.

![Open the editor](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-ingestion/OpenSpec.png)

The simplest [_dimensionsSpec_](https://druid.apache.org/docs/latest/ingestion/index.html#dimensionsspec) consists of a list of dimensions, or data columns.
Each entry in the list has the following.
- _name_ - the name of both the input record field and the table column (if these names differ, see [_transformSpec_](https://druid.apache.org/docs/latest/ingestion/index.html#transformspec))
- _type_ - the data type which can be _string_, _long_, _float_ or _double_ - the default is _string_ if not specified.

<br>
<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Replace the empty _dimensionSpec_ with the following.

```
          "dimensionsSpec" : {
            "dimensions" : [
              "user"
            ]
          },
```

Normally, you might have many dimensions, but in this example we are only using one dimension named _user_.

<br>
<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

![Save the file](https://raw.githubusercontent.com/shallada/InstruqtImages/main/druid-ingestion/SaveFile.png)

<br>
<h2 style="color:cyan">Wow! Defining Druid dimension columns is easy!</h2>