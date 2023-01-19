---
slug: spelunk-segments
id: vjxy0ptogoog
type: challenge
title: Spelunk Segments
teaser: Locate and inspect the segments loaded by the Historical process
notes:
- type: video
  url: ../assets/16-SegmentManagementExercise1.mp4
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

In this exercise, we want to understand how Druid stores segments.
Click [here](https://druid.apache.org/docs/latest/design/segments.html) to read about segment organization.

<details>
  <summary style="color:cyan"><b>Are you new to these exercises? Click here for instructions.</b></summary>
<hr style="color:cyan">
These exercises allow you to actually <i>do</i> the tasks involved in learning Druid within the comfort of your browser!<br><br>
Click on the command boxes to copy the commands to your clipboard.
Then, paste the commands in the terminal to execute them.<br><br>
Some of the steps of the exercise will require using browser tabs external to the exercise tab.
When necessary, the exercise will explain how to open these external tabs.
When working in other browser tabs, you will want to switch back and forth between the tabs.<br><br>
That's all there is to it! Enjoy!
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by creating a segment.

Run the following command to generate the data. This script will take 10+ seconds to run.

```
/root/process-monitor-producer.sh ISO 100 > /root/raw_data.csv
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, let's ingest the data and create a segment.
We've already created the ingestion spec for you (feel free to check it out in the editor).
Use the following command to ingest the data.

```
/root/apache-druid-0.21.1/bin/post-index-task \
  --file /root/ingestion-spec.json \
  --url http://localhost:8081
```

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>If the ingestion fails, you can use the editor to review the log files in the folder here: /root/apache-druid-0.21.1/var/druid/indexing-logs/.
</i></p>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Query and review the data to see what it looks like.

```
curl -s -X 'POST' \
  -H 'Content-Type:application/json' \
  -d @/root/query.json http://localhost:8888/druid/v2/sql \
  | column -t -s,
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, let's look at where Druid stores the segment files.

<p><span style="color:cyan"><strong><em>NOTE: </em></strong></span><i>In a production environment, Druid would store the segments in deep storage like S3. However, for our small educational setup, Druid uses local storage as the deep store.
</i></p>

Change directories with the following command.

```
cd /root/apache-druid-0.21.1/var/druid/segments/process-data
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, inspect the contents of the directory.

```
tree
```

The directory structure is explained in the docs [here](https://druid.apache.org/docs/latest/design/architecture.html#segment-identifiers).

_process-data_ (the current directory) is the name of the table datasource.


The subdirectory named by a time range (the top of the tree) represents the time-chunk.
If you investigate the ingestion spec, you will see that _spec.dataSchema.granularitySpec.segmentGranularity_ is set to _day_.
Therefore, the length of the time-chunk is a day.


The time-chunk directory contains a subdirectory, which is named with a timestamp based on when you performed the ingestion.
This timestamp represents the version number of the data.


Inside the timestamp directory, we see a directory named _0_, which is the partition number and contains the segment file _index.zip_.
The partition number allows Druid to order the segments.


<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Recall that after ingestion writes the segments to deep storage, the historicals load the segments into the segment cache.
Let's change directories to the segment cache.

```
cd /root/apache-druid-0.21.1/var/druid/segment-cache/process-data/
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Again, inspect the contents of the directory.

```
tree
```

We see a similar directory structure, except the files in the partition-level directory are the unzipped version of _index.zip_ we saw earlier.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Move into the partition directory.

```
cd $(ls)/$(ls $(ls))/0
```

<details>
  <summary style="color:cyan"><b>How does this command work?</b></summary>
<hr style="color:cyan">
The <i>cd</i> command takes an argument, which is the target directory.
Since there is only one time-chunk directory right now, we can use <i>$(ls)</i> to find the name of the time-chunk directory.
Similarly, there is only one version directory within the time-chunk directory, so we can get its name by doing <i>$(ls $(ls))</i>.
The final directory is the partition number, which in this case is <i>0</i>.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

We see that this directory contains 4 files.

```
ls -l
```

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:5px">

The _version.bin_ file contain a 32-bit binary number that represents the version of the segment format.
Use the hexdump utility to investigate this file's contents.

```
hd version.bin
```

We see that the version number is 9.

<details>
  <summary style="color:cyan"><b>How do I read hexdump output?</b></summary>
<hr style="color:cyan">
<i>hd</i> output consists of four columns:
<ul>
  <li>The first column is the starting offset (in hexadecimal) within the file of the data contained within the output row</li>
  <li>The second column is the hex values of the first eight bytes at the offset</li>
  <li>The third column is the hex values of the second eight bytes at the offset</li>
  <li>The fourth column is the text representation of the bytes</li>
</ul>
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:5px">

_factory.json_ is a JSON text file indicating the serialization mechanism used for the segment.

```
cat factory.json | jq
```

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:5px">

_meta.smoosh_ is a text file that describes the contents of _00000.smoosh_.
Remember, smooshing is a way of combining several files into a single file so as to avoid file descriptor overhead.


Investigate _meta.smoosh_ with the following.

```
cat meta.smoosh
```

Notice that the first line contains boiler plate info, but each of the subsequent lines describe the name and location of the file within the _00000.smoosh_ file.

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:5px">

_00000.smoosh_ is a (mostly) binary file.
Let's investigate its contents.

```
hd 00000.smoosh
```

If we scroll through the output of the hexdump of _00000.smoosh_ (looking mainly at the text representation in the fourth column of the output), we can see that most of the smooshed file sections start with a JSON header that describes the type of data within the smooshed file as well as some other metadata.

<h2 style="color:cyan">Step 14</h2><hr style="color:cyan;background-color:cyan;height:5px">


We can separate out each of these smooshed files by using the values in the third and fourth columns of the _meta.smoosh_ file.

Review the contents of _meta.smoosh_.

```
cat meta.smoosh
```

<h2 style="color:cyan">Step 15</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by extracting the <i>__time</i> file, which is a file containing all the timestamps for the table.

The following command extracts a hex dump of the <i>__time</i> file from _00000.smoosh_.

the _-s_ option specifies the starting offset within the file.

The _-n_ option specifies the number of bytes to dump.
We use the sub-command <i>$(cat meta.smoosh | grep __time | awk -F ',' '{print $4}')</i> to extract the fourth value from the _meta.smoosh_ <i>__time</i> line.

```
hd -s 0 -n $(cat meta.smoosh | grep __time | awk -F ',' '{print $4}') 00000.smoosh
```

<h2 style="color:cyan">Step 16</h2><hr style="color:cyan;background-color:cyan;height:5px">

Here's a bash command that will de-smoosh the files as hex dumps and store them in their corresponding file names.

```
cat meta.smoosh | tail -n +2 | awk -F, '{cmd="hd -s " $3 " -n " ($4-$3) " 00000.smoosh > " $1; system(cmd)}'
```

<details>
  <summary style="color:cyan"><b>How does this command work?</b></summary>
<hr style="color:cyan">
The <i>cat</i> command merely prints out the contents of <i>meta.smoosh</i> and pipes the results into <i>tail</i>.<br>
The <i>tail</i> command strips off the first boiler plate line and pipes the results to the <i>awk</i> script.<br>
For each line, the <i>awk</i> script splits the line based on commas, and uses the line contents to create an <i>hd</i> command using the arguments from the split.
The <i>awk</i> script then executes the <i>hd</i> command and redirects the results to the file named by the first argument of the line.
<hr style="color:cyan">
</details>

<h2 style="color:cyan">Step 17</h2><hr style="color:cyan;background-color:cyan;height:5px">

See the resulting files of de-smooshing.

```
ls -l
```

<h2 style="color:cyan">Step 18</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can inspect these resulting files by typing out the contents.

```
cat __time
```

The point of this exercise is that columns (and indexes) are each stored in separate files within the smoosh file.
This is worth considering when data modeling because it means that Druid can skip over unused columns, even though they are still part of the smooshed file.


Feel free to _cat_ out the contents of the other extracted files, or view them in the editor.

<h2 style="color:cyan">Wow! Now we understand how Druid stores segments!</h2>
