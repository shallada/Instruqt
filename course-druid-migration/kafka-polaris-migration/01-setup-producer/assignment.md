---
slug: setup-producer
id: e7bd1tt0i6ig
type: challenge
title: Setup a Producer
teaser: Let's setup an event producer and observe its output
notes:
- type: text
  contents: Please wait while we set up the challenge
tabs:
- title: Shell
  type: terminal
  hostname: single-server
- title: Editor
  type: code
  hostname: single-server
  path: /root
difficulty: basic
timelimit: 600
---

In this challenge, we'll run a simple Kafka producer and observe the output.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

The following command runs the producer shell script for a short period of time and prints the output to the terminal.
Run the command and observe the output.

<details>
  <summary style="color:cyan"><b>What does this shell script do? Click here.</b></summary>
<hr style="color:cyan">
This shell script monitors processes on the machine using the <i>top</i> command, and prints the results as JSON records.
The shell script is a little gnarly, but feel free to check it out in the editor tab.
<hr style="color:cyan">
</details>

```
./process-monitor-producer.sh ISO JSON 10
```

Notice that the output consists of JSON records with the following fields:
- Time of the measurement
- Process name (i.e., the command used to create the process)
- CPU utilization
- Memory utilization

<h2 style="color:cyan">Great first step! You see how to produce data and what it looks like!</h2>
