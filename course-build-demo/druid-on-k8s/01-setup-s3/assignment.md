---
slug: setup-s3
id: 93hoswkke6tb
type: challenge
title: Set up the S3 Deep Store
teaser: Set up MinIO as the S3 deep storage
notes:
- type: text
  contents: Please wait while we create the Kubernetes cluster
tabs:
- title: Shell
  type: terminal
  hostname: server
- title: Editor
  type: code
  hostname: server
  path: /root
difficulty: intermediate
timelimit: 600
---


<h2 style="color:cyan">Step 1</h2><hr style="color:cyan;background-color:cyan;height:2px">

Check out the Kubernetes cluster we have set up for you.
The cluster (named _kind_) has:
- One control plane node
- Four worker nodes
- A local Docker container registry

We have also installed _kubectl_, which is the Kubernetes command line interface.

<details>
  <summary style="color:cyan"><b>What KinD of a Kubernetes cluster are we using?</b></summary>
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
EOF
```

Note the user name and password.

<h2 style="color:cyan">Step 4</h2><hr style="color:cyan;background-color:cyan;height:2px">

Now we can install MinIO with our custom values.

```
helm install \
  -f minio_values.yaml \
  minio minio/minio
```

Forward the MinIO port (Remove this after ingress)

```
nohup kubectl port-forward   svc/minio 9000   --address 0.0.0.0 > /dev/null 2> /dev/null & disown
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
mc alias set \
  local http://localhost:9000 \
  rootuser \
  rootpass123
```

Note the use of the MinIO credentials we configured earlier.

<h2 style="color:cyan">Step 7</h2><hr style="color:cyan;background-color:cyan;height:2px">

Create a service account.

```
mc admin user svcacct \
  add local rootuser \
  --access-key access123 \
  --secret-key secret1234567890
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

<h2 style="color:cyan">Outstanding! We have set up deep storage for your K8s cluster!</h2>

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
