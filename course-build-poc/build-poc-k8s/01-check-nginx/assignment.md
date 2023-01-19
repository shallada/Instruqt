---
slug: check-nginx
id: rbbb7tyjcu4q
type: challenge
title: Check that the NGINX chart is installed
teaser: A setup script has used helm to install an NGINX chart. Verify that it worked!
notes:
- type: text
  contents: Helm is one of the most popular package managers for kubernetes!
tabs:
- title: Shell
  type: terminal
  hostname: kubernetes-vm
- title: Console
  type: website
  url: https://kubernetes-vm-8888-${_SANDBOX_ID}.env.play.instruqt.com/unified-console.html
difficulty: basic
timelimit: 3600
---
👀 Verify that Helm is available
================================

Set the POD name variable
```
export MINIO_POD_NAME=$(kubectl get pods --namespace dev -l "release=minio" -o jsonpath="{.items[0].metadata.name}")
```

Do port forwarding for MinIO server
```
kubectl port-forward $MINIO_POD_NAME 9000 --namespace dev &
```


Set alias for Minio Client

```
./mc alias set myminio http://localhost:9000 rootuser rootpass123
```

Set up Minio Client and bucket

```
./mc mb myminio/druidlocal --region us-west-1

```


Set up service account

```
./mc admin user svcacct add         \
   --access-key "access123"         \
   --secret-key "secret1234567890"  \
   myminio rootuser
```

Download druid

```
git clone https://github.com/apache/druid
cd druid
```

Update the local Helm repo with the necessary dependencies for Druid

```
helm dependency update helm/druid
```

```
cat > /root/k8s_minikube.yaml << \EOF
configVars:
  druid_extensions_loadList: '["druid-histogram","druid-datasketches","druid-lookups-cached-global","postgresql-metadata-storage","druid-s3-extensions"]'
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
image:
  tag: 0.22.1
EOF
```

```
helm install druid helm/druid --namespace dev -f /root/k8s_minikube.yaml
```

```
export DRUID_POD_NAME=$(kubectl get po -n dev | grep router | cut -d" " -f1)
kubectl port-forward pod/$DRUID_POD_NAME 8888 -n dev &
```

```
kubectl get pods -n dev
```























Helm has been installed on this virtual machine alongside an NGINX ingress controller Helm chart.

You can check that Helm is available and its version with this command:

```bash
helm version
```

You should get a message with the build info that looks like this:

```
version.BuildInfo{Version:"v3.7.2", GitCommit:"663a896f4a815053445eec4153677ddc24a0a361", GitTreeState:"clean", GoVersion:"go1.16.10"}
```

🚀 The NGINX chart is installed and the pods are running
========================================================

You can use Helm to show all the charts that are installed on this machine. To do this, run this command:

```bash
helm list
```

You will get a message with the ingress-nginx chart information, it should look like this (note that the status should be deployed):

```
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
my-ingress-nginx        default         1               2022-01-06 16:00:34.622220076 +0000 UTC deployed        ingress-nginx-4.0.13    1.1.0
```

Aditionally, you can check that the NGINX pods are running, remember that Helm works over kubernetes. Just run this command to verify that the NGINX pods are up and running:

```
kubectl get pods
```

This should show you the NGINX controller pods:

```
NAME                                          READY   STATUS    RESTARTS   AGE
svclb-my-ingress-nginx-controller-fwrxs       2/2     Running   0          3m49s
my-ingress-nginx-controller-b9d8cddf4-gwlgr   1/1     Running   0          3m49s
```

You can click the check button to finish this track!
