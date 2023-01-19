---
slug: setup-data-driver
id: avvwbkfkggt7
type: challenge
title: Set up the Data Driver
teaser: Set up a clickstream simulator
notes:
- type: text
  contents: Please wait while we set up the lab
tabs:
- title: Shell
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
timelimit: 600
---

In this lab we will configure the data generator and generate some example clickstream data.

<h2 style="color:cyan">Perform a Batch Ingestion</h2>

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

Let's run the data driver to create a batch of 100 records of clickstream data.

```
python3 /root/DruidCloudPOC/driver-code/DruidDataDriver.py \
  -n 100 \
  -f /root/DruidCloudPOC/driver-code/examples/clickstream_config.json \
  > clickstream_data.json
```

<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

In a production environment, you are likely to have batch data stored on something like an S3 drive.
We simulate this storage with MinIO.
So, move the resulting clickstream data to the MinIO bucket we created in the first lab.

```
mc cp clickstream_data.json local/druidlocal/batch-data/clickstream_data.json
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Batch ingest the data.


DESCRIBE PROCESS WITH IMAGES HERE


Path to the data:

```
s3://druidlocal/batch-data/clickstream_data.json
```

Access key:

```
access123
```

Secret key:

```
secret1234567890
```

<h2 style="color:cyan">Prepare for Streaming Ingestion</h2>

Let's prepare the data generator to run within Kubernetes and to stream data to Kafka.

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a container for the data driver and push it to the local repo.

<details>
  <summary style="color:cyan"><b>What do these commands do?</b></summary>
<hr style="background-color:cyan">
The first command makes the driver directory, which we just downloaded, the current directory.
The <i>image build</i> command creates a local Docker image named <i>data-driver</i> using the downloaded dockerfile and Python program.
The third command creates an alias for the image in the local Docker repo.
The final command pushes the image to the local Docker repo.
<hr style="background-color:cyan">
</details>


```
cd /root/DruidCloudPOC/driver-code
docker image build -t data-driver .
docker tag data-driver localhost:5001/data-driver
docker push localhost:5001/data-driver
```


<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Modify the data generation configuration file by changing the _target_ (near the top of the file) to the following as shown.

```
"target": {
  "type": "kafka",
  "endpoint": "my-kafka.default.svc.cluster.local:9092",
  "topic": "clickstream_data"
},
```

<h2 style="color:cyan">Step 6</h2><hr style="color:cyan;background-color:cyan;height:2px">

Save the file.

NEED IMAGE HERE

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a configmap from the config file.

<details>
  <summary style="color:cyan"><b>What is a configmap and why are we doing this?</b></summary>
<hr style="background-color:cyan">
A configmap is key/value dictionary that we use in Kubernetes to communicate configurations to pods. Recall that pods have their own environment including their file systems. So we can use configmaps to affect pods' environments.
<br><br>
In this case, we are using the configmap to store the entire contents of a text file as a string. This is a bit of a trick in Kubernetes we can use as a way to effectively copy a file to the pod's file system.
<hr style="background-color:cyan">
</details>

```
kubectl create configmap \
  data-driver-configmap \
  --from-file=/root/DruidCloudPOC/driver-code/examples/clickstream_config.json
```

<h2 style="color:cyan">Step 8</h2><hr style="color:cyan;background-color:cyan;height:2px">

MAKE THIS A DEPLOYMENT


Create the pod manifest.

<details>
  <summary style="color:cyan"><b>What is a pod manifest?</b></summary>
<hr style="background-color:cyan">
In Kubernetes, a manifest describes how Kubernetes should configure a resource.
The big idea in Kubernetes is that we can specify what resources  we want and what they should look like using manifest files.
Then, Kubernetes makes it happen.
<br><br>
In this case we are telling Kubernetes how to configure the pod for the data driver.
<hr style="background-color:cyan">
</details>


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
      volumeMounts:
        - name: data-driver-config
          mountPath: /driver/config
EOF
```


<h2 style="color:cyan">Great! We have set up the data driver to steam data to Kafka!</h2>



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
