---
slug: setup-druid
id: xdrx6fvewaxx
type: challenge
title: Setup Druid
teaser: Set up Druid on Kubernetes
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

In this lab we will set up Druid on Kubernetes using Helm.

<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Clone the Druid repo from GitHub.

```
git clone https://github.com/apache/druid
cd druid
```

<h2 style="color:cyan">Step 2</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a file to customize some of the values for the installation.

These values cause Druid to use S3 (or MinIO in this case) for deep storage.

```
cat > /root/druid/k8s_druid.yaml <<-EOF
configVars:
  druid_extensions_loadList: '["druid-histogram","druid-datasketches","druid-lookups-cached-global","postgresql-metadata-storage","druid-s3-extensions","druid-kafka-indexing-service"]'
  druid_storage_type: s3
  druid_storage_bucket: druidlocal
  druid_storage_baseKey: k8s-druid/segments
  druid_s3_accessKey: access123
  druid_s3_secretKey: secret1234567890
  AWS_REGION: "us-east-1"
  druid_s3_forceGlobalBucketAccessEnabled: "false"
  druid_storage_disableAcl: "true"
  druid_indexer_logs_type: s3
  druid_indexer_logs_s3Bucket: druidlocal
  druid_indexer_logs_s3Prefix: k8s-druid/logs
  druid_indexer_logs_disableAcl: "true"
  druid_s3_endpoint_signingRegion: "us-east-1"
  druid_s3_endpoint_url: "http://minio:9000"
  druid_s3_protocol: "http"
  druid_s3_enablePathStyleAccess: "true"
EOF
```

With our S3 deep store emulator (i.e., MinIO) in place, We can configure and install Druid.


<h2 style="color:cyan">Step 3</h2><hr style="color:cyan;background-color:cyan;height:2px">

Update the Helm charts for Druid.
This command verifies that the required charts are set up correctly.

```
helm dependency update helm/druid
```

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Perform the Druid install using the file created in a previous step.

```
helm install \
  druid helm/druid \
  -f k8s_druid.yaml
```

<h2 style="color:cyan">Step 5</h2><hr style="color:cyan;background-color:cyan;height:2px">

Monitor the pods until they all have a _Status_ of _Running_ and all pods have a _Ready_ value of _1/1_.
This may take several minutes and pods may restart.
Once the pods are ready, use _Ctrl-C_ to exit the watch loop.

```
watch kubectl get pods
```

Forward the router port - remove this once the ingress is set up.

```
nohup kubectl port-forward   svc/druid-router 8888   --address 0.0.0.0 > /dev/null 2> /dev/null & disown
```

<h2 style="color:cyan">Excellent! We have Druid running in your K8s cluster with an S3 deep store!</h2>
