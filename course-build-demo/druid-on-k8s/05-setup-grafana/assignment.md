---
slug: setup-grafana
id: u2ke7tl9kmxq
type: challenge
title: Set up Grafana
teaser: Let's use Grafana to visualize the clickstream data
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
- title: Grafana
  type: service
  hostname: server
  path: /
  port: 3000
- title: Editor
  type: code
  hostname: server
  path: /root
difficulty: basic
timelimit: 7200
---

```
kubectl create configmap grafana-configmap --from-file=/root/clickstream_dashboard.json
```


(fix the dashboardsConfigMaps)
```
cat > grafadruid-druid-datasource.yaml <<-EOF
plugins: "grafadruid-druid-datasource"
dashboardsConfigMaps:
  - configMapName: grafana-configmap
    folderName: /root
    fileName: clickstream_dashboard.json
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

Wait for Grafana to come up:

```
watch kubectl get pods
```

Forward the Grafana port

```
nohup kubectl port-forward svc/grafana 3000 --address 0.0.0.0  > /dev/null 2> /dev/null & disown
```


Data source seriesOverrides

```
echo http://server.${_SANDBOX_ID}.instruqt.io:8888/
```
