---
slug: how-to-read-log-entries
id: xyyxkrfilg9z
type: challenge
title: Reading Druid Log Files
teaser: Learn how to decipher Druid's log file entries
notes:
- type: video
  url: ../assets/02-UnderstandingLogEvents.mp4
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

Druid log files consist of messages describing process activities.
At first glance, these messages seem a bit cryptic.
Let's investigate the messages in detail so we can understand them.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's start by looking at the most recent message from the Coordinator-Overlord's log file.

```
tail -n 1 /root/apache-druid-24.0.0/log/coordinator-overlord.log
```

In this message we see fields indicating the following:
- Date/time of the message (at the beginning of the line)
- Log severity (e.g., INFO, WARN, DEBUG, etc.)
- Originating thread name (in brackets e.g., [])
- Originating class name (the long string of dot-separated names)
- Message text (after the dash)

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Druid uses the Log4J2 logging utility.
This utility determines the format of the log message based on a config file named _log4j2.xml_.


Open the _log4j2.xml_ configuration as follows.


<details>
  <summary style="color:cyan"><b>Which <i>log4j2.xml</i> file should we open?</b></summary>
<hr style="background-color:cyan">
If we look around in this file structure, we will see multiple instances of files with this name.
Since this lab uses the nano-quickstart single server startup file, we need to use the instance under the <i>nano-quickstart</i> directory.
<hr style="background-color:cyan">
</details>


<a href="#img-2">
  <img alt="Open log4j.xml" src="../assets/Openlog4J2Config.png" />
</a>
<a href="#" class="lightbox" id="img-2">
  <img alt="Open log4j.xml" src="../assets/Openlog4J2Config.png" />
</a>

We see that the _log4j2.xml_ file contains three sections:

<details>
  <summary style="color:cyan"><b>Properties</b></summary>
<hr style="background-color:cyan">
<i>Properties</i> provide key/values pairs that may be used throughout the configuration file.
<br><br>
As an example, the key <i>druid.log.path</i> has a value of <i>log</i>, which is dereferenced as <i>${sys:druid.log.path}</i>.
Read more <a href="https://logging.apache.org/log4j/2.x/manual/configuration.html#PropertySubstitution" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<details>
  <summary style="color:cyan"><b>Appenders</b></summary>
<hr style="background-color:cyan">
<i>Appenders</i> designate the format (e.g., <i>PatternLayout</i>) of log messages and determine the target (e.g. <i>FileName</i>) for the messages.
Read more <a href="https://logging.apache.org/log4j/2.x/manual/appenders.html" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<details>
  <summary style="color:cyan"><b>Loggers</b></summary>
<hr style="background-color:cyan">
<i>Loggers</i> filter the log messages and dispense them to Appenders.
Loggers filter messages based on the Java package and/or class using the <i>name</i> field, and by log level severity using the <i>level</i> field.
Read more <a href="https://logging.apache.org/log4j/2.x/manual/configuration.html#Loggers" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>
<br><br>
<details>
  <summary style="color:cyan"><b>What does <i>Status=warn</i> do?</b></summary>
<hr style="background-color:cyan">
This clause sets the value for messages emitted by the Log4J2 internals, as opposed to Druid internals.
<hr style="background-color:cyan">
</details>


Let's make some adjustments to the log configuration and see the effects!

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

A simple change we can make is to set the Logger Root level to _DEBUG_.
Within the _Loggers_ section replace the <i>&lt;Root level="info"&gt;</i> with the following:

```
<Root level="debug">
```


<a href="#img-3">
  <img alt="Change Root Log Level" src="../assets/ChangeRootLogLevel.png" />
</a>
<a href="#" class="lightbox" id="img-3">
  <img alt="Change Root Log Level" src="../assets/ChangeRootLogLevel.png" />
</a>

<details>
  <summary style="color:cyan"><b>What does Logger Root do?</b></summary>
<hr style="background-color:cyan">
The Logger Root is the default log level.
Loggers can define a package/class and log level.
However, in the absence of a matching Logger, Log4J2 filters using the Logger Root level.
<br><br>
Generally, we would prefer to change the level of a more specific package or class, since changing the root level will generate too many logging events.
But in this exercise, we are changing the root level to make the effects of changing the logging level obvious.
<hr style="background-color:cyan">
</details>


<details>
  <summary style="color:cyan"><b>What are log levels?</b></summary>
<hr style="background-color:cyan">
Druid assigns each log message a <i>log level</i>.
These levels include (in order of descending severity):
<ol>
<li><b>FATAL</b> - System-wide functionality failed</li>
<li><b>ERROR</b> - A specific functionality failed</li>
<li><b>WARN</b> - Unexpected behavior occurred, but functionality continues</li>
<li><b>INFO</b> - An informative event occurred</li>
<li><b>DEBUG</b> - An event useful for debugging occurred</li>
<li><b>TRACE</b> - Step by step execution of events</li>
</ol>
<br>
When loggers filter by specified log level, then loggers include messages of the specified level as well as any more severe levels.
<br><br>
So, for example, a logger with a specified level of <i>WARN</i> would emit message of level <i>WARN</i>, <i>ERROR</i>, and <i>FATAL</i>.
Therefore, loggers with less severe levels will emit more messages.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Next, let's modify the pattern of the log message format.
In the _Appenders.RollingRandomAccessFile_ section, change the _PatternLayout_ to the following, which includes the file name and line number of the source of the message:

```
<PatternLayout pattern="%d{ISO8601} %p [%t] %c (%F:%L) - %m%n"/>
```

<a href="#img-4A">
  <img alt="Replace Pattern Layout" src="../assets/ReplacePatternLayout.png" />
</a>
<a href="#" class="lightbox" id="img-4A">
  <img alt="Replace Pattern Layout" src="../assets/ReplacePatternLayout.png" />
</a>


<details>
  <summary style="color:cyan"><b>How does <i>PatternLayout</i> work?</b></summary>
<hr style="background-color:cyan">
<i>PatternLayout</i> is a formatting pattern where the tokens having a percent (<i>%</i>) get replaced by message specific values.
So, by modifying the pattern, we can change what Druid includes in the log messages.
Read more <a href="https://logging.apache.org/log4j/1.2/apidocs/org/apache/log4j/PatternLayout.html" target="_blank">here</a>.
<br><br>
Click on the following diagram to enlarge it - then click again to reduce it.
<a href="#img-4B">
  <img alt="Pattern Layout Example" src="../assets/PatternLayoutExample.png" />
</a>
<a href="#" class="lightbox" id="img-4B">
  <img alt="Pattern Layout Example" src="../assets/PatternLayoutExample.png" />
</a>
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Save the config file by clicking on the "save file" icon.

<a href="#img-5">
  <img alt="Save Log4J2 Config" src="../assets/SaveLog4J2Config.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="Save Log4J2 Config" src="../assets/SaveLog4J2Config.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Back in the _Shell_ tab, bounce the Druid cluster to cause the changes to take effect.

```
kill $(ps -ef | grep 'perl /root' | awk 'NF{print $2}' | head -n 1)
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -eq 0 ]; do echo "Waiting for cluster to terminate..."; sleep 3; done
nohup /root/apache-druid-24.0.0/bin/start-nano-quickstart > /root/log.out 2> /root/log.err < /dev/null & disown
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]; do echo "Waiting for cluster to initialize..."; sleep 3; done
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Now, look for _DEBUG_ log messages in the Coordinator-Overlord log file.

```
cat /root/apache-druid-24.0.0/log/coordinator-overlord.log \
  | grep DEBUG \
  | tail -n 1
```

Now, we see the debug message with the new message format.


Feel free to open the various log files in the editor to review the effects of the changes (Note that you will need to scroll down to the messages that occurred after the configuration change).

<h2 style="color:cyan">Outstanding! Now we can make sense of Druid's log messages!</h2>


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
