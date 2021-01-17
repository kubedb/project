# Backup Elasticsearch using Stash

This demo will show how to backup Elasticsearch using Stash.

## Demo Environment

- **Kubernetes Version:**

```bash
❯ kubectl version --short
Client Version: v1.20.2
Server Version: v1.19.1
```

- **Operators:**

```bash
❯ helm ls -n kube-system
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
kubedb-catalog          kube-system     1               2021-01-17 21:44:09.226331612 +0600 +06 deployed        kubedb-catalog-v0.16.1          v0.16.1    
kubedb-community        kube-system     1               2021-01-17 21:43:06.227294933 +0600 +06 deployed        kubedb-v0.16.1                  v0.16.1    
kubedb-enterprise       kube-system     1               2021-01-17 22:01:05.638546168 +0600 +06 deployed        kubedb-enterprise-v0.3.1        v0.3.1     
stash-enterprise        kube-system     1               2021-01-17 21:46:09.427815685 +0600 +06 deployed        stash-enterprise-v0.11.8        v0.11.8 
```

- **Stash Addons:**

```bash
❯ helm ls | grep stash-elasticsearch
stash-elasticsearch-5.6.4-v5    default         1               2021-01-17 22:06:12.096298402 +0600 +06 deployed        stash-elasticsearch-5.6.4-v5    5.6.4-v5   
stash-elasticsearch-6.2.4-v5    default         1               2021-01-17 22:06:14.089241173 +0600 +06 deployed        stash-elasticsearch-6.2.4-v5    6.2.4-v5   
stash-elasticsearch-6.3.0-v5    default         1               2021-01-17 22:06:15.686566635 +0600 +06 deployed        stash-elasticsearch-6.3.0-v5    6.3.0-v5   
stash-elasticsearch-6.4.0-v5    default         1               2021-01-17 22:06:17.388869639 +0600 +06 deployed        stash-elasticsearch-6.4.0-v5    6.4.0-v5   
stash-elasticsearch-6.5.3-v5    default         1               2021-01-17 22:06:19.289632312 +0600 +06 deployed        stash-elasticsearch-6.5.3-v5    6.5.3-v5   
stash-elasticsearch-6.8.0-v5    default         1               2021-01-17 22:06:20.916712816 +0600 +06 deployed        stash-elasticsearch-6.8.0-v5    6.8.0-v5   
stash-elasticsearch-7.2.0-v5    default         1               2021-01-17 22:06:22.670051656 +0600 +06 deployed        stash-elasticsearch-7.2.0-v5    7.2.0-v5   
stash-elasticsearch-7.3.2-v5    default         1               2021-01-17 22:06:24.079195406 +0600 +06 deployed        stash-elasticsearch-7.3.2-v5    7.3.2-v5 
```

## Prepare Database

- **Deploy Elasticsearch:**

```yaml
apiVersion: kubedb.com/v1alpha2
kind: Elasticsearch
metadata:
  name: sample-elasticsearch
  namespace: demo
spec:
  version: 7.5.2-searchguard
  replicas: 1
  storageType: Durable
  storage:
    resources:
      requests:
        storage: 1Gi
    storageClassName: standard
  podTemplate:
    spec:
      resources:
        requests:
          cpu: "300m"
          memory: "1Gi"
        limits:
          cpu: "300m"
          memory: "1Gi"
  terminationPolicy: Delete
```

```bash
❯ kubectl apply -f ./elasticsearch.yaml
elasticsearch.kubedb.com/sample-elasticsearch created
```

- **Export Auth Credentials:**

```bash
❯ kubectl get secret -n demo | grep sample-elasticsearch
sample-elasticsearch-admin-cred             kubernetes.io/basic-auth              2      3m37s
sample-elasticsearch-ca-cert                kubernetes.io/tls                     2      3m38s
sample-elasticsearch-config                 Opaque                                3      3m36s
sample-elasticsearch-kibanaro-cred          kubernetes.io/basic-auth              2      3m37s
sample-elasticsearch-kibanaserver-cred      kubernetes.io/basic-auth              2      3m37s
sample-elasticsearch-logstash-cred          kubernetes.io/basic-auth              2      3m37s
sample-elasticsearch-readall-cred           kubernetes.io/basic-auth              2      3m37s
sample-elasticsearch-snapshotrestore-cred   kubernetes.io/basic-auth              2      3m37s
sample-elasticsearch-token-wqhk5            kubernetes.io/service-account-token   3      3m36s
sample-elasticsearch-transport-cert         kubernetes.io/tls                     3      3m37s
```

```bash
❯ export USER=$(kubectl get secrets -n demo sample-elasticsearch-admin-cred -o jsonpath='{.data.\username}' | base64 -d)
❯ export PASSWORD=$(kubectl get secrets -n demo sample-elasticsearch-admin-cred -o jsonpath='{.data.\password}' | base64 -d)
```

- **Port-forward Service:**

```bash
❯ kubectl get service -n demo
NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
sample-elasticsearch          ClusterIP   10.102.101.207   <none>        9200/TCP   22m
sample-elasticsearch-master   ClusterIP   None             <none>        9300/TCP   22m
sample-elasticsearch-pods     ClusterIP   None             <none>        9200/TCP   22m
```

```bash
❯ kubectl port-forward -n demo services/sample-elasticsearch 9200
Forwarding from 127.0.0.1:9200 -> 9200
Forwarding from [::1]:9200 -> 9200
```

#### Insert Sample Data

- Show available indexes

```bash
❯ curl -X GET "$USER:$PASSWORD@localhost:9200/_cat/indices?v&s=index&pretty"

health status index                  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   .signals_accounts      -FiF7-u8T16E_LSrzjDQdQ   1   1          0            0       283b           283b
yellow open   .signals_settings      AT6j7FiFSD2Cm8qj8cJVGw   1   1          2            0      7.7kb          7.7kb
yellow open   .signals_watches       mbHWBRpFQCi-WcTjuH3WxA   1   1          0            0       283b           283b
yellow open   .signals_watches_state mkb5-wwERaKqCICHCTaOcg   1   1          0            0       283b           283b
green  open   searchguard            gzWWXFVNRImrkvwRIFeFqg   1   0          6            0     32.2kb         32.2kb
```

- Insert a sample data

```bash
❯ curl -X POST "$USER:$PASSWORD@localhost:9200/products/_doc?pretty" -H 'Content-Type: application/json' -d'
{
    "name": "KubeDB",
    "vendor": "AppsCode Inc.",
    "description": "Database Operator for Kubernetes"
}
'
```

- Insert another sample data

```bash
❯ curl -X POST "$USER:$PASSWORD@localhost:9200/products/_doc?pretty" -H 'Content-Type: application/json' -d'
{
    "name": "Stash",
    "vendor": "AppsCode Inc.",
    "description": "Backup tool for Kubernetes workloads"
}
'
```

- Verify that index `products` has been created automatically

```bash
❯ curl -X GET "$USER:$PASSWORD@localhost:9200/_cat/indices?v&s=index&pretty"
health status index                  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   .signals_accounts      -FiF7-u8T16E_LSrzjDQdQ   1   1          0            0       283b           283b
yellow open   .signals_settings      AT6j7FiFSD2Cm8qj8cJVGw   1   1          2            0      7.7kb          7.7kb
yellow open   .signals_watches       mbHWBRpFQCi-WcTjuH3WxA   1   1          0            0       283b           283b
yellow open   .signals_watches_state mkb5-wwERaKqCICHCTaOcg   1   1          0            0       283b           283b
yellow open   products               CFJJ03YKSmes3qbsElrJ_Q   1   1          0            0       230b           230b
green  open   searchguard            gzWWXFVNRImrkvwRIFeFqg   1   0          6            0     32.2kb         32.2kb
```

- Show all the documents of `products` index

```bash
❯ curl -X GET "$USER:$PASSWORD@localhost:9200/products/_search?pretty"
{
  "took" : 94,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "nENWEXcBHnFP5BMBS9vt",
        "_score" : 1.0,
        "_source" : {
          "name" : "KubeDB",
          "vendor" : "AppsCode Inc.",
          "description" : "Database Operator for Kubernetes"
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "nUNYEXcBHnFP5BMBHtsL",
        "_score" : 1.0,
        "_source" : {
          "name" : "Stash",
          "vendor" : "AppsCode Inc.",
          "description" : "Backup tool for Kubernetes workloads"
        }
      }
    ]
  }
}
```

## Backup

**Create Repository Secret:**

```bash
❯ kubectl create secret generic -n demo gcs-secret \
    --from-file=./RESTIC_PASSWORD \
    --from-file=./GOOGLE_PROJECT_ID \
    --from-file=./GOOGLE_SERVICE_ACCOUNT_JSON_KEY
```

**Create Repository:**

```yaml
apiVersion: stash.appscode.com/v1alpha1
kind: Repository
metadata:
  name: gcs-repo
  namespace: demo
spec:
  backend:
    gcs:
      bucket: stash-testing
      prefix: /backup/elasticsearch/sample-elasticsearch
    storageSecretName: gcs-secret
```

```bash
❯ kubectl apply -f ./repository.yaml
repository.stash.appscode.com/gcs-repo created
```

**Check AppBinding:**

```bash
❯ kubectl get appbinding -n demo
NAME                   TYPE                       VERSION   AGE
sample-elasticsearch   kubedb.com/elasticsearch   7.5.2     72m
```

```yaml
❯ kubectl get appbinding -n demo sample-elasticsearch -o yaml
apiVersion: appcatalog.appscode.com/v1alpha1
kind: AppBinding
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"kubedb.com/v1alpha2","kind":"Elasticsearch","metadata":{"annotations":{},"name":"sample-elasticsearch","namespace":"demo"},"spec":{"podTemplate":{"spec":{"resources":{"limits":{"cpu":"300m","memory":"1Gi"},"requests":{"cpu":"300m","memory":"1Gi"}}}},"replicas":1,"storage":{"resources":{"requests":{"storage":"1Gi"}},"storageClassName":"standard"},"storageType":"Durable","terminationPolicy":"Delete","version":"7.5.2-searchguard"}}
  creationTimestamp: "2021-01-17T16:20:43Z"
  generation: 1
  labels:
    app.kubernetes.io/component: database
    app.kubernetes.io/instance: sample-elasticsearch
    app.kubernetes.io/managed-by: kubedb.com
    app.kubernetes.io/name: elasticsearches.kubedb.com
  name: sample-elasticsearch
  namespace: demo
  ownerReferences:
  - apiVersion: kubedb.com/v1alpha2
    blockOwnerDeletion: true
    controller: true
    kind: Elasticsearch
    name: sample-elasticsearch
    uid: 8a635433-3b99-4408-ace8-6c0bc047e1b3
  resourceVersion: "7770"
  selfLink: /apis/appcatalog.appscode.com/v1alpha1/namespaces/demo/appbindings/sample-elasticsearch
  uid: 704b29c8-d617-4686-866f-6e9317a76612
spec:
  clientConfig:
    service:
      name: sample-elasticsearch
      port: 9200
      scheme: http
  secret:
    name: sample-elasticsearch-admin-cred
  type: kubedb.com/elasticsearch
  version: 7.5.2
```

**Create BackupConfiguration:**

```yaml
apiVersion: stash.appscode.com/v1beta1
kind: BackupConfiguration
metadata:
  name: sample-elasticsearch-backup
  namespace: demo
spec:
  schedule: "*/5 * * * *"
  task:
    name: elasticsearch-backup-7.3.2-v5
    params:
    - name: args
      value: --includeType=data
  repository:
    name: gcs-repo
  target:
    ref:
      apiVersion: appcatalog.appscode.com/v1alpha1
      kind: AppBinding
      name: sample-elasticsearch
  interimVolumeTemplate:
    metadata:
      name: stash-backup-tmp-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 1Gi
  retentionPolicy:
    name: keep-last-5
    keepLast: 5
    prune: true
```

```bash
❯ kubectl apply -f ./backupconfig.yaml
backupconfiguration.stash.appscode.com/sample-elasticsearch-backup created
```

**Wait for BackupSession:**

```bash
❯ kubectl get backupsession -n demo  -w
NAME                                     INVOKER-TYPE          INVOKER-NAME                  PHASE     AGE
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Running     19s
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Running     34s
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Running     47s
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Running     47s
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Running     47s
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Running     48s
sample-elasticsearch-backup-1610909709   BackupConfiguration   sample-elasticsearch-backup   Succeeded   48s
```

## Restore

**Pause Backup Temporarily:**

```bash
❯ kubectl patch backupconfiguration -n demo sample-elasticsearch-backup --type="merge" --patch='{"spec": {"paused": true}}'
backupconfiguration.stash.appscode.com/sample-elasticsearch-backup patched
```

**Delete sample data:**

```bash
❯ curl -X DELETE "$USER:$PASSWORD@localhost:9200/products?pretty"
{
  "acknowledged" : true
}
```

**Verify that the Index has been deleted:**

```bash
❯ curl -X GET "$USER:$PASSWORD@localhost:9200/_cat/indices?v&s=index&pretty"
health status index                  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   .signals_accounts      -FiF7-u8T16E_LSrzjDQdQ   1   1          0            0       283b           283b
yellow open   .signals_settings      AT6j7FiFSD2Cm8qj8cJVGw   1   1          2            0      7.7kb          7.7kb
yellow open   .signals_watches       mbHWBRpFQCi-WcTjuH3WxA   1   1          0            0       283b           283b
yellow open   .signals_watches_state mkb5-wwERaKqCICHCTaOcg   1   1          0            0       283b           283b
green  open   searchguard            gzWWXFVNRImrkvwRIFeFqg   1   0          6            0     32.2kb         32.2kb
```

**Create RestoreSession:**

```yaml
apiVersion: stash.appscode.com/v1beta1
kind: RestoreSession
metadata:
  name: sample-elasticsearch-restore
  namespace: demo
  labels:
    app.kubernetes.io/name: elasticsearches.kubedb.com
spec:
  task:
    name: elasticsearch-restore-7.3.2-v5
    params:
    - name: args
      value: --includeType=data
  repository:
    name: gcs-repo
  target:
    ref:
      apiVersion: appcatalog.appscode.com/v1alpha1
      kind: AppBinding
      name: sample-elasticsearch
  interimVolumeTemplate:
    metadata:
      name: stash-restore-tmp-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 1Gi
  rules:
  - snapshots: [latest]
```

```bash
❯ kubectl apply -f ./restoresession.yaml
restoresession.stash.appscode.com/sample-elasticsearch-restore created
```

**Wait for RestoreSession Succeeded:**

```bash
❯ kubectl get restoresession -n demo -w
NAME                           REPOSITORY   PHASE       AGE
sample-elasticsearch-restore   gcs-repo     Running     2
sample-elasticsearch-restore   gcs-repo     Succeeded   33
```

**Verify Index has been Restored:**

```bash
❯ curl -X GET "$USER:$PASSWORD@localhost:9200/_cat/indices?v&s=index&pretty"
health status index                  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
yellow open   .signals_accounts      -FiF7-u8T16E_LSrzjDQdQ   1   1          0            0       283b           283b
yellow open   .signals_settings      AT6j7FiFSD2Cm8qj8cJVGw   1   1          2            0      7.7kb          7.7kb
yellow open   .signals_watches       mbHWBRpFQCi-WcTjuH3WxA   1   1          0            0       283b           283b
yellow open   .signals_watches_state mkb5-wwERaKqCICHCTaOcg   1   1          0            0       283b           283b
yellow open   products               onig-AGqR-OmufaDORfjBw   1   1          1            0      4.8kb          4.8kb
green  open   searchguard            gzWWXFVNRImrkvwRIFeFqg   1   0          6            0     32.2kb         32.2kb
```

**Verify Index Data Has Been Restored:**

```bash
❯ curl -X GET "$USER:$PASSWORD@localhost:9200/products/_search?pretty"
{
  "took" : 94,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 1.0,
    "hits" : [
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "nENWEXcBHnFP5BMBS9vt",
        "_score" : 1.0,
        "_source" : {
          "name" : "KubeDB",
          "vendor" : "AppsCode Inc.",
          "description" : "Database Operator for Kubernetes"
        }
      },
      {
        "_index" : "products",
        "_type" : "_doc",
        "_id" : "nUNYEXcBHnFP5BMBHtsL",
        "_score" : 1.0,
        "_source" : {
          "name" : "Stash",
          "vendor" : "AppsCode Inc.",
          "description" : "Backup tool for Kubernetes workloads"
        }
      }
    ]
  }
}
```
