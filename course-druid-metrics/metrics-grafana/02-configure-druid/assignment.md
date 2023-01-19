---
slug: configure-druid
id: b6tuwmpf4ids
type: challenge
title: Configure Druid
teaser: Let's configure Druid to emit metrics to Prometheus
notes:
- type: video
  url: ../assets/04-ConfigDruidProme.mp4
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
- title: Prometheus Console
  type: website
  url: https://container-9090-${_SANDBOX_ID}.env.play.instruqt.com
difficulty: basic
timelimit: 600
---

In the previous exercise we set up Prometheus.
In this exercise let's configure Druid to emit metrics to Prometheus, and then Launch Druid.


Read more about the Prometheus emitter <a href="https://druid.apache.org/docs/latest/development/extensions-contrib/prometheus.html" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

We've already downloaded Druid for you, so all we need to do is configure it to work with Prometheus.
Start by installing the Druid extensions for the Prometheus emitter with the following command.

Read more about this command <a href="https://druid.apache.org/docs/latest/development/extensions.html#loading-community-extensions" target="_blank">here</a>.


```
pushd /root/apache-druid-24.0.0
java \
  -cp "lib/*" \
  -Ddruid.extensions.directory="extensions" \
  -Ddruid.extensions.hadoopDependenciesDir="hadoop-dependencies" \
  org.apache.druid.cli.Main tools pull-deps \
  --no-default-hadoop \
  -c "org.apache.druid.extensions.contrib:prometheus-emitter:24.0.0"
popd
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

Configure all the Druid processes to use the Prometheus emitter by modifying the common runtime properties with the following _sed_ commands.

```
sed -i 's/druid.extensions.loadList=\[/druid.extensions.loadList=\["prometheus-emitter", /g' \
  /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/_common/common.runtime.properties
sed -i 's/noop/prometheus/g' \
  /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/_common/common.runtime.properties
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

Modify each of the Druid process configuration files to configure the emitter port for that process.
This is as easy as adding the required configuration line <a href="https://druid.apache.org/docs/latest/development/extensions-contrib/prometheus.html#configuration" target="_blank">(see the docs)</a> to each of the process runtime properties individually.
So we can use a simple _echo >>_ command here to append the necessary configuration lines.

```
echo 'druid.emitter.prometheus.port=9091' \
  >> /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/broker/runtime.properties
echo 'druid.emitter.prometheus.port=9092' \
  >> /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/coordinator-overlord/runtime.properties
echo 'druid.emitter.prometheus.port=9093' \
  >> /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/historical/runtime.properties
echo 'druid.emitter.prometheus.port=9094' \
  >> /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/middleManager/runtime.properties
echo 'druid.emitter.prometheus.port=9095' \
  >> /root/apache-druid-24.0.0/conf/druid/single-server/nano-quickstart/router/runtime.properties
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Start Druid and wait for it to initialize.

```
nohup /root/apache-druid-24.0.0/bin/start-nano-quickstart \
  > /root/log.out 2> /root/log.err \
  < /dev/null & disown
while [ $(curl localhost:8888/ 2>&1 >/dev/null | grep Fail | wc -w) -gt 0 ]
do
  echo "Waiting for Druid to initialize..."
  sleep 3
done
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

Since we’ve configured the Prometheus Emitter on each Druid process with its own port, we can curl these emitters' ports to see the metrics the emitters provide.
Let's try hitting the Broker emitter to see an example of the metrics Prometheus will retrieve.

```
curl localhost:9091 | tail -10
```

Notice that the comments above the actual metrics describe what the metrics monitor.
For example, you may see something like the following:

```
# HELP druid_query_wait_time_created Seconds spent waiting for a segment to be scanned.
# TYPE druid_query_wait_time_created gauge
druid_query_wait_time_created 1.669740725945E9
```

Where:
- _HELP_ describes the metric - in this case it's the time spent scanning segments
- _TYPE_ describes the metric type, which in this case is a _gauge_ or value
- _druid_query_wait_time_created_ is the metric label with the associated measured value

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can verify that Prometheus is storing these metrics by performing a query using the Prometheus console.
The simplest Prometheus query consists merely of the name of the metric.


Click on the _Prometheus Console_ tab, paste the following metric name, and click _Execute_.

```
druid_query_wait_time_created
```

<a href="#img-6">
  <img alt="Execute Prometheus Query" src="../assets/ExecPromQuery.png" />
</a>
<a href="#" class="lightbox" id="img-6">
  <img alt="Execute Prometheus Query" src="../assets/ExecPromQuery.png" />
</a>


We see results from each of the Druid processes as indicated by the port number.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

We can use Prometheus's command completion to see a list of available metrics.


Refresh the Prometheus console and type in _druid_ to see the full list.
Then, select <i>druid_jvm_mem_used</i> and click _Execute_.

<a href="#img-7">
  <img alt="Prometheus Metrics List" src="../assets/PromMetricsList.png" />
</a>
<a href="#" class="lightbox" id="img-7">
  <img alt="Prometheus Metrics List" src="../assets/PromMetricsList.png" />
</a>

<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>If you don't see any JVM metrics in the list, it may be because no JVM metrics have been emitted yet.
Wait a bit and refresh the Prometheus console.
Eventually, the JVM metrics will appear in the list.</i></p>
<hr style="background-color:cyan">


The results show us raw JVM memory numbers for various points in time.

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

We would really like to see this data in a graphical format.
Click the _Graph_ tab.

<a href="#img-8">
  <img alt="Prometheus Graph" src="../assets/PromGraph.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Prometheus Graph" src="../assets/PromGraph.png" />
</a>

You can hover over the various lines to get an explanation of each data point.
This graph-view is much better than the raw numbers.
But, what would be even more helpful would be a graphical dashboard that would allow us to correlate data from various metrics on the same page.

We'll see how we can use Grafana to create such a dashboard.

<h2 style="color:cyan">Step 9</h2><hr style="color:cyan;background-color:cyan;height:5px">

As a last step, peruse, investigate and become familiar with the various metrics that Druid provides by scrolling through the metrics list.

<a href="#img-9">
  <img alt="Prometheus Scroll List" src="../assets/PromScroll.png" />
</a>
<a href="#" class="lightbox" id="img-9">
  <img alt="Prometheus Scroll List" src="../assets/PromScroll.png" />
</a>


<h2 style="color:cyan">Super! Druid is configured and emitting metrics to Prometheus!</h2>


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
