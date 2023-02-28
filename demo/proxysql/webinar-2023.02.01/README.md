### Install KubeDB

```bash
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
$ helm install kubedb appscode/kubedb \
  --version v2023.01.31 \
  --namespace kubedb --create-namespace \
  --set kubedb-provisioner.enabled=true \
  --set kubedb-ops-manager.enabled=true \
  --set kubedb-autoscaler.enabled=true \
  --set kubedb-dashboard.enabled=true \
  --set kubedb-schema-manager.enabled=true \
  --set-file global.license=/path/to/the/license.txt
```

### Install Cert-manager

```bash
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
```

### Create ca and ca-secret

```bash
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ca.key -out ./ca.crt -subj "/CN=mysql/O=kubedb"
$ kubectl create ns demo
$ kubectl create secret tls my-ca \
    --cert=ca.crt \
    --key=ca.key \
    --namespace=demo
```

### Create Issuer

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubedb/project/master/demo/proxysql/webinar-2023.02.01/issuer.yaml
```

### Deploy MariaDB

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubedb/project/master/demo/proxysql/webinar-2023.02.01/mariadb.yaml
```

### Deploy Percona-XtraDB

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubedb/project/master/demo/proxysql/webinar-2023.02.01/xtradb.yaml
```

### Deploy ProxySQL

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubedb/project/master/demo/proxysql/webinar-2023.02.01/proxysql-mariadb.yaml
$ kubectl apply -f https://raw.githubusercontent.com/kubedb/project/master/demo/proxysql/webinar-2023.02.01/proxysql-xtradb.yaml
```

### Install Prometheus

```bash
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --set grafana.image.tag=7.5.5 --create-namespace
```

### Install Penopticon

```bash
helm install panopticon appscode/panopticon -n kubeops \
    --create-namespace \
    --set monitoring.enabled=true \
    --set monitoring.agent=prometheus.io/operator \
    --set monitoring.serviceMonitor.labels.release=prometheus \
    --set-file license=<path-to-license>
```

### Install kubedb-metrics CRD and CRs

```bash
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
$ helm search repo appscode/kubedb-metrics --version=v2023.01.31
$ helm upgrade -i kubedb-metrics appscode/kubedb-metrics -n kubedb --create-namespace --version=v2023.01.31
```

### Grafana Dashboard JSONs 

Repository : https://github.com/appscode/grafana-dashboards/tree/master/proxysql

General Insight : https://github.com/appscode/grafana-dashboards/blob/master/proxysql/proxysql-database.json

Pod Insight : https://github.com/appscode/grafana-dashboards/blob/master/proxysql/proxysql-pod.json

Summary : https://github.com/appscode/grafana-dashboards/blob/master/proxysql/proxysql-summary.json

### Install Prometheus Alert chart

Repository : https://github.com/appscode/alerts/tree/master/charts/proxysql

```bash
$ helm install proxy-server-mariadb -n demo  <path-to-helm-chart> 
$ helm install proxy-server-xtradb -n demo  <path-to-helm-chart> 
```

### Useful Links
KubeDB ProxySQL Doc : https://kubedb.com/docs/v2023.01.31/guides/proxysql/

KubeDB Official Doc : https://kubedb.com/

AppsCode License Server : https://license-issuer.appscode.com/