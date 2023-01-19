---
slug: install-prometheus
id: avxyjy5srrfd
type: challenge
title: Install Prometheus
teaser: Let's install and configure Prometheus to work with Druid
notes:
- type: video
  url: ../assets/03-MetricsPrometheus.mp4
tabs:
- title: Shell
  type: terminal
  hostname: container
- title: Editor
  type: code
  hostname: container
  path: /root
- title: Prometheus Console
  type: website
  url: https://container-9090-${_SANDBOX_ID}.env.play.instruqt.com
difficulty: basic
timelimit: 600
---

This lab consists of three exercises, which configure and install Prometheus, Druid and Grafana, respectively.
In this first exercise will focus on Prometheus.

<details>
  <summary style="color:cyan"><b>What is Prometheus?</b></summary>
<hr style="background-color:cyan">
Prometheus is a time series database that we will use to capture the Druid metrics.
Read about Prometheus <a href="https://prometheus.io/" target="_blank">here</a>.
Prometheus and Grafana are a common toolset that many systems use for monitoring.
<br><br>
If you are wondering if we could use Druid to capture metrics, the answer is yes!
However, many people are more familiar with using Prometheus, so because of this familiarity, we'll use Prometheus in this lab.
<br><br>
Also, the point of capturing metrics in Prometheus is <i>NOT</i> so we can query Prometheus directly, but as a metrics-store for Grafana.
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Download Prometheus.

```
wget https://github.com/prometheus/prometheus/releases/download/v2.40.2/prometheus-2.40.2.linux-amd64.tar.gz
tar -xzf  /root/prometheus-2.40.2.linux-amd64.tar.gz
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">
Configure Prometheus to work with Druid.

<details>
  <summary style="color:cyan"><b>What does this command do?</b></summary>
<hr style="background-color:cyan">
This <i>sed</i> command changes the Prometheus configuration file to cause Prometheus to poll ports 9091-9095 instead of port 9090 (the default).
We will later configure each of the Druid processes to emit metrics using these ports - one per Druid process.
<hr style="background-color:cyan">
</details>

```
sed -i 's/\["localhost:9090"\]/\["localhost:9091", "localhost:9092", "localhost:9093", "localhost:9094", "localhost:9095"\]/g' \
  /root/prometheus-2.40.2.linux-amd64/prometheus.yml
```

<details>
  <summary style="color:cyan"><b>How does Prometheus work with Druid?</b></summary>
<hr style="background-color:cyan">
Prometheus polls target services for metrics, and then stores those metrics.
We will configure each of the Druid processes with a Prometheus emitter which will provide an endpoint target for Prometheus.
Since we are running a single node Druid cluster, each of these target endpoints must use a separate port.
The <i>sed</i> command above changes the Prometheus configuration file so that Prometheus will use all the endpoints in the list.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Start Prometheus.

```
pushd /root/prometheus-2.40.2.linux-amd64
nohup /root/prometheus-2.40.2.linux-amd64/prometheus --config.file=./prometheus.yml > /root/prometheus.log 2> /root/prometheus.err & disown
popd
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's verify Prometheus is running by clicking on the _Prometheus Console_ tab.

<a href="#img-4">
  <img alt="Click Prometheus" src="../assets/ClickPrometheus.png" />
</a>
<a href="#" class="lightbox" id="img-4">
  <img alt="Click Prometheus" src="../assets/ClickPrometheus.png" />
</a>

If you see the console, you are good to go!


<h2 style="color:cyan">Great! Prometheus is running!</h2>


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
