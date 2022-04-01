---
slug: druid-install
id: fcjxyaum04mf
type: challenge
title: Let's Install Druid
teaser: Learn how to install and run Druid
notes:
- type: video
  url: ../assets/Splash1Video.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
difficulty: basic
timelimit: 600
---

<details>
  <summary style="color:cyan"><b>Are you new to these exercises? Click here for instructions.</b></summary>
<hr style="background-color:cyan">
These exercises allow you to actually <i>do</i> the tasks involved in learning Druid within the comfort of your browser!<br><br>
Click on the command boxes to copy the commands to your clipboard.
Then, paste the commands in the terminal to execute them.
That's all there is to it! Enjoy!
<hr style="background-color:cyan">
</details>

Here's what the [official website](https://druid.apache.org/docs/0.21.1/tutorials/index.html#requirements) says we need in order to run Druid.

TL;DR we need an environment with Java 8 installed (including the JAVA_HOME environment variable).
Let's verify our environment is ready to go.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

First, look at the Java version.

```
java -version
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Next, check that <i>JAVA_HOME</i> is set correctly.

```
echo $JAVA_HOME
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Download Druid (here's a [list of mirror sites](https://www.apache.org/dyn/closer.cgi?path=/druid/0.21.1/apache-druid-0.21.1-bin.tar.gz) if you want to find one close to your location).
Depending on the download speed, this may take a few minutes.

```
wget https://ftp.wayne.edu/apache/druid/0.21.1/apache-druid-0.21.1-bin.tar.gz
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Unzip the downloaded file.

```
tar -xzf apache-druid-0.21.1-bin.tar.gz
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

We'll start Druid with _nohup_ so that the Druid processes persist between Instruqt challenges.

<details>
  <summary style="color:cyan"><b><i>nohup</i> is scary! How would I run Quickstart Druid without <i>nohup</i>? Click here.</b></summary>
<hr style="background-color:cyan">
Don't let the <code>nohup</code> command scare you.
At its core, here's the real command to start Druid.
<code>/root/apache-druid-0.21.1/bin/start-nano-quickstart</code>
All the other trimmings are just to allow the Druid processes to continue running when we move to the next lab.
<hr style="background-color:cyan">
</details>

```
nohup /root/apache-druid-0.21.1/bin/start-nano-quickstart > /root/apache-druid-0.21.1/log.out 2> /root/apache-druid-0.21.1/log.err < /dev/null & disown
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

You can see the various Druid processes with this command.
(Yeah, this command looks a bit gnarly, but just trust us on this one)

```
ps -ef | grep "Main server [A-Za-z]*$" | awk 'NF{print $NF}'
```

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>In this quickstart, the coordinator and overlord run in the same process named coordinator.
Also, we aren't showing the ZooKeeper process in the list.</i></p>
<hr style="background-color:cyan">


<h2 style="color:cyan">Outstanding! Druid is up and running!</h2>
