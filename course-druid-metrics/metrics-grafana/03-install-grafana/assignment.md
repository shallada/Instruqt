---
slug: install-grafana
id: ifikyyh7eji3
type: challenge
title: Install Grafana
teaser: Let's install Grafana
notes:
- type: video
  url: ../assets/05-ConfigureGrafana.mp4
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
- title: Grafana Console
  type: website
  url: https://container-3000-${_SANDBOX_ID}.env.play.instruqt.com
difficulty: basic
timelimit: 600
---

In the previous exercises, we set up Druid to emit metrics to Prometheus.
In this exercise we'll install Grafana so we can visualize the metrics.

Read more about Grafana <a href="https://grafana.com/" target="_blank">here</a>.


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:5px">

Install Grafana.

```
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install grafana
sed -i 's/;allow_embedding = false/allow_embedding = true/g' \
  /etc/grafana/grafana.ini
sed -i 's/\[auth.anonymous\]/\[auth.anonymous\]\nenabled = true\norg_name = Main Org.\norg_role = Viewer/g' \
  /etc/grafana/grafana.ini
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:5px">

We'll provision Grafana to use Prometheus as a data source by creating the following Grafana configuration file.

<details>
  <summary style="color:cyan"><b>What does this file do?</b></summary>
<hr style="background-color:cyan">
Grafana needs to know what data source(s) to use and where to find the data source(s).
In this file, we create a YAML list of data sources with a single entry for Prometheus.
The notable fields in this entry include the <i>type</i> field, which tells Grafana to use the Prometheus protocol for querying the data source, and the <i>url</i> field, which tells Grafana where to talk to the Proemtheus data source.
<br><br>
Grafana will read this configuration file when it starts up and perform queries accordingly.
<br><br>
Alternatively, we could have added the data source using the Grafana console as detailed <a href="https://prometheus.io/docs/visualization/grafana/" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>


```
cat > /etc/grafana/provisioning/datasources/prom.yml << \EOF
apiVersion: 1

datasources:
- name: prometheusdata
  type: prometheus
  access: proxy
  orgId: 1
  url: http://localhost:9090
  isDefault: true
  version: 1
  editable: false
EOF
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:5px">

We have provisioned a dashboard for this lab in the _/root/dashboards_ directory.
Create the following file, which tells Grafana where to find the dashboard.

```
cat > /etc/grafana/provisioning/dashboards/dashboards.yml << \EOF
apiVersion: 1

providers:
  - name: dashboards
    type: file
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /root/dashboards
      foldersFromFilesStructure: true
EOF
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:5px">

Start Grafana as a service.

```
service grafana-server start > /dev/null
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:5px">

View the Druid Metrics dashboard.


<hr style="background-color:cyan">
<p><span style="color:cyan"><strong><em>NOTE:</em></strong></span> <i>This is an example dashboard that demonstrates some of the various views available for Druid metrics in Grafana.
In your own deployment, you would want to configure a dashboard specifically tailored to your needs.
Read more about creating Grafana dashboards <a href="https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/" target="_blank">here</a>.</i></p>
<hr style="background-color:cyan">

<a href="#img-5">
  <img alt="View Dashboard" src="../assets/ViewDashboard.png" />
</a>
<a href="#" class="lightbox" id="img-5">
  <img alt="View Dashboard" src="../assets/ViewDashboard.png" />
</a>


<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:5px">

Let's create some Druid activity by ingesting and querying data.
Back in the _Shell_ tab, execute the following commands to perform an ingestion.

```
TASK_ID=$(curl -XPOST \
  -H'Content-Type: application/json'   \
  http://localhost:8888/druid/v2/sql/task \
  -d @/root/ingestion.json \
  | tee >(jq > /dev/tty) \
  | jq -r '.taskId')
sleep 3
while [ $(curl  -H'Content-Type: application/json' http://localhost:8888/druid/indexer/v1/task/$TASK_ID/reports  2> /dev/null \
  | jq .multiStageQuery.payload.status.status 2> /dev/null \
  | grep SUCCESS | wc -w) -eq 0 ]; \
  do
    echo "Waiting for ingestion to complete..."
     sleep 3
  done
echo "Ingestion completing"
sleep 5
```

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:5px">

Finally, execute the following (which will run forever) to create query activity.

```
while true
do
  curl -s -X 'POST' \
    -H 'Content-Type:application/json' \
    -d @/root/query.json http://localhost:8888/druid/v2/sql \
    | jq
done
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:5px">

Switch back to the Gafana Console and investigate the effects of the Druid activity.

<a href="#img-8">
  <img alt="Grafana Dashboard" src="../assets/GrafanaDash.png" />
</a>
<a href="#" class="lightbox" id="img-8">
  <img alt="Grafana Dashboard" src="../assets/GrafanaDash.png" />
</a>

At the top of the dashboard, you see the current JVM garbage collection CPU activity by process.
Next on the page you see query-related histograms.
The query activity we are introducing here isn't very interesting, so all the queries are very fast (probably less than 0.1 second) - we will address more interesting workloads in the Clarity labs.
You can scroll down further in the dashboard to see other example metrics and ways to display them.


Notice that the Grafana dashboard is more helpful than the Prometheus console because we can label the various process-related metrics with the process names.
Also, we can correlate various metrics within a single view.


However, if you have ever tried to create Grafana dashboards, you will realize that it can be a bit of a tedious art-form.
This is why Clarity is a very helpful product - Clarity gives you a tailored view of Druid metrics with none of the configuration tedium.

<h2 style="color:cyan">Excellent! We can visualize Druid metrics!</h2>


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
