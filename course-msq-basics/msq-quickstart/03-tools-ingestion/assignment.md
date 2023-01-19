---
slug: tools-ingestion
id: rlbqocio0xmw
type: challenge
title: Helpful SQL Tools
teaser: Use the Druid console to help you generate SQL ingestion queries
notes:
- type: video
  url: ../assets/03-ToolsIngestion.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
- title: Druid Console
  type: website
  url: https://container-8443-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
difficulty: basic
timelimit: 900
---
We can use the Druid Console to generate SQL ingestion queries.
In this lab, we'll show you two useful approaches.

- Use the external data connection wizard
- Convert a JSON ingestion spec

<h2 style="color:cyan">Use External Connection Wizard to Generate SQL</h2>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Druid Console_ tab.

<a href="#img-1">
  <img alt="Click Druid Console" src="../assets/ClickDruidConsole.png" />
</a>
<a href="#" class="lightbox" id="img-1">
  <img alt="Click Druid Console" src="../assets/ClickDruidConsole.png" />
</a>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Query_ tab.

<a href="#img-2">
  <img alt="Click Query Tab" src="../assets/ClickQueryTab.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Click Query Tab" src="../assets/ClickQueryTab.png" />
</a>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click the _Connect external data_ link.

<a href="#img-3">
  <img alt="Connect External Data" src="../assets/ConnectExternalData.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Connect External Data" src="../assets/ConnectExternalData.png" />
</a>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Copy the URL for the external data and then fill out the wizard form as shown.

```
https://static.imply.io/gianm/wikipedia-2016-06-27-sampled.json
```

<a href="#img-4">
  <img alt="Fill Out Input Form" src="../assets/FillOutInputForm.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Fill Out Input Form" src="../assets/FillOutInputForm.png" />
</a>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Verify the values that the console has selected.
Notice that the console has determined that the external file contains JSON.
The console has also suggested that the time column might be _timestamp_.


Both of these conjectures are correct, so click _Done_.

<a href="#img-5">
  <img alt="Review Form" src="../assets/ReviewForm.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Review Form" src="../assets/ReviewForm.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Review the SQL that the Druid console generated to ingest the data.
This SQL ingests the same data as we did in the previous lab.
You will see many similarities to the previous lab's SQL, but you will notice some differences too.

<h2 style="color:cyan">Convert JSON Ingestion Spec to SQL</h2>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Now, let's generate SQL from a JSON ingestion spec.
Start by clicking on the ellipses (near the middle of the screen near the _Run_ button).
Then, select _Convert ingestion spec to SQL_.

<details>
  <summary style="color:cyan"><b>What is a JSON ingestion spec?</b></summary>
<hr style="background-color:cyan">
Prior to the introduction of the MSQ framework, one performed an ingestion by creating a JSON-based ingestion spec.
While these JSON ingestion specs have a great deal of flexibility, for the uninitiated, they were a bit daunting.
<br><br>
Now, with SQL-based ingestion, we can use a much more familiar language.
However, for those who still use JSON ingestion specs, it's nice to know there is an easy way to convert them to SQL.
<hr style="background-color:cyan">
</details>

<a href="#img-7">
  <img alt="Start JSON Conversion" src="../assets/StartJSONConversion.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Start JSON Conversion" src="../assets/StartJSONConversion.png" />
</a>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Copy the following JSON ingestion spec and paste as shown and click _Submit_.

```
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "wikipedia",
            "timestampSpec": {
                "column": "time",
                "format": "auto"
            },
            "dimensionsSpec": {
                "dimensions": [
                    "user"
                ]
            },
            "metricsSpec": [
                {
                    "type": "count",
                    "name": "recordSum"
                },
                {
                    "fieldName": "added",
                    "name": "addedSum",
                    "type": "longSum"
                },
                {
                    "fieldName": "deleted",
                    "name": "deletedSum",
                    "type": "longSum"
                },
                {
                    "fieldName": "delta",
                    "name": "deltaSum",
                    "type": "longSum"
                }
            ],
            "granularitySpec": {
                "segmentGranularity": "day",
                "queryGranularity": "hour",
                "intervals": [
                    "2015-09-12/2015-09-13"
                ],
                "rollup": true
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
              "type": "http",
              "uris": [
                "https://static.imply.io/gianm/wikipedia-2016-06-27-sampled.json"
              ],
              "httpAuthenticationUsername": null,
              "httpAuthenticationPassword": null
            },
            "inputFormat": {
                "type": "json"
            },
            "appendToExisting": false
        },
        "tuningConfig" : {
            "type" : "index_parallel",
            "maxRowsInMemory" : 25000,
            "maxBytesInMemory" : 250000,
            "partitionSpec" : {
              "type" : "dynamic",
              "maxRowsPerSegment" : 5000000
            }
        }
    }
}
```

<a href="#img-8">
  <img alt="Paste JSON Spec" src="../assets/PasteJSONSpec.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Paste JSON Spec" src="../assets/PasteJSONSpec.png" />
</a>

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:2px">

Finally, review the SQL that the Druid console generated from the ingestion spec.
You see that it looks very similar to the SQL generated in the previous steps.

<h2 style="color:cyan">Outstanding! Now, you know two ways to generate SQL ingestion queries using the Druid console!</h2>


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
