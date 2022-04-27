---
slug: setup-master
id: lxwxjpnvq0cy
type: challenge
title: Set Up the Master Server
teaser: Learn how to deploy the Druid master server
notes:
- type: video
  url: ../assets/01splash.mp4
tabs:
- title: Master-shell
  type: terminal
  hostname: master-server
- title: Master-editor
  type: code
  hostname: master-server
  path: /root
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

Our Druid deployment will use four servers.

<a href="#img-0">
  <img alt="Druid Server Architecture" src="../assets/servers.png" />
</a>

<a href="#" class="lightbox" id="img-0">
  <img alt="Druid Server Architecture" src="../assets/servers.png" />
</a>

We need to install the Druid software and configure it on each of the servers.
In this challenge, we'll deploy the master server and lay the foundation for the other servers.

<details>
  <summary style="color:cyan">What are the tabs we'll use in this track? Click here to find out.</b></summary>
<hr style="background-color:cyan">
We will deploy Druid using four servers.
In each challenge, as we set up another server, we will add another tab which will give you Bash shell access to the server.
<br>
<br>
Besides the Bash shell tabs, there is one additional tab, which is an editor tab on the master server.
We will use this editor to edit files on the master server and then copy them as needed to the other servers.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Start by downloading the Druid distribution.

```
wget https://ftp.wayne.edu/apache/druid/0.21.1/apache-druid-0.21.1-bin.tar.gz
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Unzip the downloaded file.

```
tar -xzf apache-druid-0.21.1-bin.tar.gz
```

In this challenge, we will be working with servers that are smaller than you would normally use in production.
For educational purposes, these smaller servers will suffice.


But to deploy on these smaller servers, we need to restrict the amount of memory the various processes use.
To do this, we will use the same configuration files we used in the single server quickstart example.

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">


Let's review the changes that we will cause by using the quickstart configuration.

```
diff /root/apache-druid-0.21.1/conf/druid/single-server/nano-quickstart/coordinator-overlord/jvm.config /root/apache-druid-0.21.1/conf/druid/cluster/master/coordinator-overlord/jvm.config
```

These changes show Java command options that will decrease the JVM heap size from 15GB to 256MB.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Now, let's copy this configuration file into our cluster configuration.

```
cp /root/apache-druid-0.21.1/conf/druid/single-server/nano-quickstart/coordinator-overlord/jvm.config /root/apache-druid-0.21.1/conf/druid/cluster/master/coordinator-overlord
```

We need to configure the servers so that they can discover each other.

<details>
  <summary style="color:cyan">Want to know how the discovery process works? Click here.</b></summary>
<hr style="background-color:cyan">
<ol>
<li>On each server, in the common configuration file, we set <i>druid.zk.service.host</i> to tell the server how to contact ZooKeeper</li>
<li>In this same common configuration file we comment out <i>druid.host</i>, which forces the server to automatically determine its host name</li>
<li>Each server contacts ZooKeeper and registers who and where they are</li>
<li>Finally, ZooKeeper tells each of the servers how to contact other processes within the cluster</li>
</ol>
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Click on the _Master-editor_ tab in the top-left corner of this screen.

<a href="#img-5">
  <img alt="Click Master-editor tab" src="../assets/ClickMasterEditor.png" />
</a>

<a href="#" class="lightbox" id="img-5">
  <img alt="Click Master-editor tab" src="../assets/ClickMasterEditor.png" />
</a>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Open the file: <i>/root/apache-druid-0.21.1/conf/druid/cluster/_common/common.runtime.properties</i>.

<a href="#img-6">
  <img alt="Common Proper File Path" src="../assets/CommonFilePath.png" />
</a>

<a href="#" class="lightbox" id="img-6">
  <img alt="Common Proper File Path" src="../assets/CommonFilePath.png" />
</a>

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Search for line _druid.host=localhost_ and comment the line out using a pound-sign (`#`).

Also, search for _druid.zk.service.host_ and change its value (which is currently _localhost_) to

```
master-server:2181
```

<a href="#img-7">
  <img alt="Change Values" src="../assets/ChangeValuesMaster.png" />
</a>

<a href="#" class="lightbox" id="img-7">
  <img alt="Change Values" src="../assets/ChangeValuesMaster.png" />
</a>

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file by clicking on the save icon in the tab.

<a href="#img-8">
  <img alt="Save File Changes" src="../assets/SaveFileChanges.png" />
</a>

<a href="#" class="lightbox" id="img-8">
  <img alt="Save File Changes" src="../assets/SaveFileChanges.png" />
</a>

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>Be sure to save the file.
Modified files show a blue dot in the editor tab, so if you see the blue dot, you still need to save the file.</i>
<hr style="background-color:cyan">


<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:2px">

Return to the Master-shell tab.

<a href="#img-9">
  <img alt="Click Master-shell tab" src="../assets/ClickMasterShell.png" />
</a>

<a href="#" class="lightbox" id="img-9">
  <img alt="Click Master-shell tab" src="../assets/ClickMasterShell.png" />
</a>

<h2 style="color:cyan">Step 10</h2><hr style="color:cyan;background-color:cyan;height:2px">

Now, we can launch the master server.
We will use _nohup_ here so that the process doesn't die when we move to the next challenge.

```
nohup /root/apache-druid-0.21.1/bin/start-cluster-master-with-zk-server > /root/apache-druid-0.21.1/log.out 2> /root/apache-druid-0.21.1/log.err < /dev/null & disown
```

<h2 style="color:cyan">Step 11</h2><hr style="color:cyan;background-color:cyan;height:2px">

Check that ZooKeeper and the coordinator processes are running (you should see two Java processes near the bottom of the list of processes).

```
ps -ef
```

<h2 style="color:cyan">Step 12</h2><hr style="color:cyan;background-color:cyan;height:2px">

We can make sure that the running master server is using our configuration changes by querying its status API.
The following command queries the API for _druid.zk.service.host_, which is the setting we changed (you may have to wait a minute for the web server to initialize).

```
curl master-server:8081/status/properties | jq | grep druid.zk.service.host
```

<h2 style="color:cyan">Step 13</h2><hr style="color:cyan;background-color:cyan;height:2px">

We can also query the API to make sure that _druid.host_ is not set (because we commented it out).
The following command should _not_ find _druid.hosts_ in the master-server properties.

```
curl master-server:8081/status/properties | jq | grep druid.host
```

<h2 style="color:cyan">Step 14</h2><hr style="color:cyan;background-color:cyan;height:2px">

You can find the log files for these processes here:

```
tail /root/apache-druid-0.21.1/var/sv/coordinator-overlord.log
```

and here:

```
tail /root/apache-druid-0.21.1/var/sv/zk.log
```

<h2 style="color:cyan">Great! You have deployed the master server.</h2>

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
