---
slug: transform-filter
id: tdjryfvisnxc
type: challenge
title: Using Ingestion Transforms to Filter Rows
teaser: Ingest only those rows you need for your queries
notes:
- type: video
  url: ../assets/09-TransformExercise6.mp4
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

So far, we have seen how to transform values, but the _transformSpec_ can also filter rows based on dimension values.


In this exercise, let's use a simple filter to only keep those rows associated with _Broker_, _MiddleManger_ and _Router_.
What do these process names have in common?
They all end in "_er_".
So, we can cause Druid to ingest only these rows using a simple regular expression filter.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

In the editor, open the ingestion spec (_ingestion-spec.json_).

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Within the _transformSpec_ let's create a filter to keep only those rows with a process name that ends in "_er_".

After the _transforms_ list, create an empty filter object (don't forget the comma after the _transforms_ list).

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
The empty filter object should look like this:
<pre><code>"filter": {
}
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

The _filter_ object has three properties (you can review the format in the [docs](https://druid.apache.org/docs/latest/ingestion/ingestion-spec.html#transformspec)).
The first property is _type_, and we set its value to _regex_ so we can use the regular expression filter.
Add this property to the filter.

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
The filter should look like this:
<pre><code>"filter": {
    "type": "regex"
}
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

The next filter property, _dimension_, specifies the name of the column we will match with the regular expression.
In this example, we'll match the _processName_ dimension.
Add this property to the filter.

<details>
  <summary style="color:cyan"><b>Need more help?</b></summary>
<hr style="color:cyan">
Now, the filter should look like this:
<pre><code>"filter": {
    "type": "regex",
    "dimension": "processName"
}
</code></pre>
<hr style="color:cyan">
</details>

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>Filtering occurs after transforms.
So, we are applying the regular expression to the process name <i>after</i> we have made the first character of the name uppercase.
</i></p>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, the last property of this filter is _pattern_ and has the value of the regular expression we want to use.


The regular expression filter uses [Java regular expressions](https://docs.oracle.com/javase/6/docs/api/java/util/regex/Pattern.html).
Since we want process names that end in "_er_", we want to match any character (_._) one or more times (_+_) followed by _er_.
So, our pattern looks like this: "_.+er_".


Add the _pattern_ property to the filter.

<details>
  <summary style="color:cyan"><b>Need some help?</b></summary>
<hr style="color:cyan">
You want the filter to look like this:
<pre><code>"filter": {
  "type": "regex",
  "dimension": "processName",
  "pattern": ".+er"
}
</code></pre>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the file.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the shell, ingest the data using the following command.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
# now wait for new segments to load
until curl localhost:8888/druid/coordinator/v1/datasources/process-data/loadstatus?forceMetadataRefresh=true 2> /dev/null | \
  grep -q '"process-data":100'
  do
    sleep 1
  done
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

In this query, notice how you only see process names that end in "_er_" (like _Broker_, _MiddleManger_ and _Router_), and you don't see process names like _Historical_ or _Coordinator_.
Also, notice that these names are the transformed names (i.e., names that have an uppercase first character due to the transform).

<h2 style="color:cyan">Superb! You have filtered rows from the raw data.</h2>
