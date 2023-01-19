---
slug: understand-your-data
id: 2eyrnhnw35gb
type: challenge
title: Understand your data
teaser: Build a super-sonic Druid system by understanding your data
notes:
- type: text
  contents: Please wait while we set up the lab
tabs:
- title: Shell
  type: terminal
  hostname: server
- title: Minio Shell
  type: terminal
  hostname: server
- title: Druid Shell
  type: terminal
  hostname: server
- title: Druid Console
  type: service
  hostname: server
  path: /unified-console.html
  port: 8888
- title: Editor
  type: code
  hostname: server
  path: /root
difficulty: basic
timelimit: 7200
---

TODOs:
- fix the Grafana dashboard to work with clickstream data
- add ingress to remove port forwarding
- add commands to wait for pods to be up
- add necessary services in front of pods
- Add dropdowns explaining what was installed by setup script
- format with steps, etc.


<h2 style="color:cyan">Your Kubernetes KinD cluster</h2>

<details>
  <summary style="color:cyan"><b>What is KinD?</b></summary>
<hr style="background-color:cyan">
KinD is Kubernetes running in a Docker container!
Docker containers are great because they provide a light-weight self-contained environment.
Normally, Kubernetes manages multiple containers.
In this case we will run Kubenetes in a container that will manage containers.
It's a bit recursive, but KinD provides a friendly Kubernetes training environment.
<br><br>
You can read more about KinD <a href="https://kind.sigs.k8s.io/" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Check out the Kubernetes cluster we have set up for you.
The cluster (named _kind_) has:
- One control plane node
- Four worker nodes
- A local Docker container registry

We have also installed _kubectl_, which is the Kubernetes command line interface.

```
kubectl get nodes
```


<h2 style="color:cyan">Set up MinIO</h2>

<details>
  <summary style="color:cyan"><b>What is MinIO?</b></summary>
<hr style="background-color:cyan">
MinIO is a multi-cloud object store that is S3-compatible.
We will use MinIO to simulate S3 services for deep storage using our local machine's storage.
<br><br>
You can read more about MinIO <a href="https://docs.min.io/" target="_blank">here</a>.
<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

We'll use Helm to install MinIO.
Add the MinIO helm chart to the helm repo.

```
helm repo add minio https://charts.min.io/
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a file specifying the customizations we want to use when installing MinIO.

```
cat > /root/minio_values.yaml <<-EOF
mode: standalone
replicas: 1
rootUser: rootuser
rootPassword: rootpass123
persistence:
  size: 50Gi
  enabled: true
resources:
  requests:
    memory: 512M
environment:
  MINIO_SITE_REGION: “us-west-1”
EOF
```

Note the user name, password and region.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Now we can install MinIO with our custom values.

```
helm install -f minio_values.yaml minio minio/minio
```

Forward the MinIO port (Remove this after ingress)

```
export MINIO_POD_NAME=$(kubectl get pods -l "release=minio" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 9001 --address 0.0.0.0 > /dev/null 2> /dev/null &
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Install the MinIO clent (_mc_).

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mv mc /usr/local/bin

```

<h2 style="color:cyan">Set up the MinIO bucket</h2>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create an alias to facilitate MinIO access.

```
mc alias set local http://localhost:9000 rootuser rootpass123
```

Note the use of the MinIO credentials we configured earlier.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a service account.

```
mc admin user svcacct add local rootuser --access-key access123 --secret-key secret1234567890

```

Note the access key and secret key values associated with the service account.


<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create the MinIO bucket.

```
mc mb local/druidlocal
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

Restart MinIO.

```
mc admin service restart local/
```



















<h2 style="color:cyan">Generate example data</h2>

In this lab we will configure the data generator and generate some example clickstream data.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's download the data generator program.

<details>
  <summary style="color:cyan"><b>Want to know more about the data generator?</b></summary>
<hr style="background-color:cyan">
The data generator is a Python program that resides in a GitHub repo within the <i>driver-code</i> directory.
Also, in this directory you find documentation explaining how to use the program as well as several example configuration files.
<br><br>
In this lab, we show you how to download the repo in case you want to use the data generator for your own demo.
<hr style="background-color:cyan">
</details>


```
git clone https://github.com/implydata/DruidCloudPOC.git
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a container for the data driver and push it to the local repo.

```
cd /root/DruidCloudPOC/driver-code
docker image build -t data-driver .
docker tag data-driver localhost:5001/data-driver
docker push localhost:5001/data-driver
```

Start Kafka

```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-kafka bitnami/kafka
```

Create a topic

```
kubectl run my-kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.2.1-debian-11-r4 --namespace default --command -- sleep infinity
watch kubectl get pods
```

```
kubectl exec --tty -i my-kafka-client --namespace default -- /bin/bash \
  -c "kafka-topics.sh \
  --create \
  --topic clickstream_data \
  --bootstrap-server my-kafka.default.svc.cluster.local:9092"
```

Modify clickstream_config.json by replacing the target.

```
"target": {
  "type": "kafka",
  "endpoint": "my-kafka-0.my-kafka-headless.default.svc.cluster.local:9092",
  "topic": "clickstream_data"
},
```


Create a configmap from the config file

```
kubectl create configmap data-driver-configmap --from-file=/root/DruidCloudPOC/driver-code/examples/clickstream_config.json
```


Create the pod manifest.

```
cat > /root/DruidCloudPOC/driver-code/driver-code.yaml <<-EOF
apiVersion: v1
kind: Pod
metadata:
  name: data-driver-pod
spec:
  volumes:
    - name: data-driver-config
      configMap:
        name: data-driver-configmap
        items:
        - key: clickstream_config.json
          path: data_driver_config.json
  containers:
    - name: data-driver
      image: localhost:5001/data-driver
      command: ["python", "DruidDataDriver.py"]
      args:
        - "-f"
        - "/driver/config/data_driver_config.json"
        - "-n"
        - "100"
      volumeMounts:
        - name: data-driver-config
          mountPath: /driver/config
EOF
```

Launch the Pod as a producer

```
kubectl apply -f /root/DruidCloudPOC/driver-code/driver-code.yaml
```

Start the Kafka consumer

```
kubectl exec --tty -i my-kafka-client -- /bin/bash \
  -c "kafka-console-consumer.sh \
    --bootstrap-server my-kafka.default.svc.cluster.local:9092 \
    --topic clickstream_data \
    --from-beginning"
```

# Set up MinIO

Switch to Minio Shell


Add the Minio helm repo

```
helm repo add minio https://charts.min.io/
```

Create the values files

```
cat > /root/minio_values.yaml <<-EOF
mode: standalone
replicas: 1
rootUser: rootuser
rootPassword: rootpass123
persistence:
  size: 50Gi
  enabled: true
resources:
  requests:
    memory: 512M
environment:
  MINIO_SITE_REGION: “us-west-1”
EOF
```

Install Minio

```
helm install --create-namespace -f minio_values.yaml minio minio/minio
```

Forward the Minio console port

```
export POD_NAME=$(kubectl get pods -l "release=minio" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 9000 &
kubectl port-forward $POD_NAME 9001 --address 0.0.0.0 &
```

# Set up bucket and creds

Switch to Shell tab


Install the Minio Client (mc)

```
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
mv mc /usr/local/bin
```


Create a MinIO alias

```
mc alias set local http://localhost:9000 rootuser rootpass123
```

Create a service account

```
mc admin user svcacct add local rootuser --access-key access123 --secret-key secret1234567890
```

Create the MinIO bucket

```
mc mb local/druidlocal
```

Restart MinIO

```
mc admin service restart local/
```





# Setup Druid

Switch to Druid Shell

Clone Druid

```
git clone https://github.com/apache/druid
cd druid
```

```
cat > /root/druid/k8s_druid.yaml <<-EOF
configVars:
  druid_extensions_loadList: '["druid-histogram","druid-datasketches","druid-lookups-cached-global","postgresql-metadata-storage","druid-s3-extensions","druid-kafka-indexing-service"]'
  druid_storage_type: s3
  druid_storage_bucket: druidlocal
  druid_storage_baseKey: k8s-minikube/segments
  druid_s3_accessKey: access123
  druid_s3_secretKey: secret1234567890
  AWS_REGION: "us-west-1"
  druid_s3_forceGlobalBucketAccessEnabled: "false"
  druid_storage_disableAcl: "true"
  druid_indexer_logs_type: s3
  druid_indexer_logs_s3Bucket: druidlocal
  druid_indexer_logs_s3Prefix: k8s-minikube/logs
  druid_indexer_logs_disableAcl: "true"
  druid_s3_endpoint_signingRegion: "us-west-1"
  druid_s3_endpoint_url: "http://minio:9000"
  druid_s3_protocol: "http"
  druid_s3_enablePathStyleAccess: "true"
EOF
```


```
helm dependency update helm/druid
```

```
helm install druid helm/druid -f k8s_druid.yaml
```

```
watch kubectl get pods
```


```
export ROUTER_POD_NAME=$(kubectl get pod | grep router | cut -d" " -f1)
kubectl port-forward --address 0.0.0.0 pod/$ROUTER_POD_NAME 8888
```

# Load data from Kafka

Click on Druid Console

Click _Load Data_

Bootstrap server:

```
my-kafka.default.svc.cluster.local:9092
```

Topic:
```
clickstream_data
```


# Install Grafana


(this needs fixing to use correct dashboard file)

```
touch /root/clickstream_dash.json
kubectl create configmap grafana-configmap --from-file=/root/clistream_dash.json
```


(fix the dashboardsConfigMaps)
```
cat > grafadruid-druid-datasource.yaml <<-EOF
plugins: "grafadruid-druid-datasource"
dashboardsConfigMaps:
  - configMapName: grafana-configmap
admin:
  user: "admin"
  password: "admin"
EOF
```

Use this command to investigate the Helm chart configuration parameters

```
helm show values bitnami/grafana > x
```

Install Grafana
```
helm install grafana bitnami/grafana -f grafadruid-druid-datasource.yaml
```

Forward the Grafan port

```
kubectl port-forward svc/grafana 3000 --address 0.0.0.0 &
```

























<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

In the editor tab, open the file named _ClickstreamConfig.json_.

You notice that this file contains the outline of the configuration file.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Let's fill out the user _interarrvial_ section by replacing the _interarrvial_ object with the following.

```
"interarrival": {
  "type": "exponential",
  "value": 10
},
```

<details>
  <summary style="color:cyan"><b>Want to know more?</b></summary>
<hr style="background-color:cyan">
The <i>interarrival</i> section of the configuration file describes how frequently entities enter the state machine.
In our case these entities represent users showing up at our website.
<br><br>
We describe the interarrival time as a distribution.
In this case we use an exponential distribution with a mean interarrival time of 10 seconds.
<br><br>
If you are familiar with queuing theory, you will recognize that an exponential distribution is useful for representing the arrival of entities in an open system such as cars arriving at a traffic light (as opposed to a closed system such as cars crossing a line on a circular race track).
<hr style="background-color:cyan">
</details>


<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

We want to create a probabilistic state machine as shown in this diagram.


Here's the JSON that describes the state machine.

```
JSON State code goes here
```

<details>
  <summary style="color:cyan"><b>Want a more detailed explanation?</b></summary>
<hr style="background-color:cyan">

<hr style="background-color:cyan">
</details>

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

We'll create specifications for the records that each state produces

<details>
  <summary style="color:cyan"><b>Want a more detailed explanation?</b></summary>
<hr style="background-color:cyan">

<hr style="background-color:cyan">
</details>

```
JSON emitter code goes here
```










<h2 style="color:cyan">Outstanding! We have generated some sample data!</h2>

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
