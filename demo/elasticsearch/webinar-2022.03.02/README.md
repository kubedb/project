# KubeDB: Elasticsearch Hot-Warm-Cold Architecture Management with Kibana in Kubernetes

- Create namespace `log-manager`
```
$ kubectl create ns log-manager
```

- For this demo we are going to use an Elasticsearch topology cluster with Hot-Warm-Cold Architecture
- Deploy Elasticsearch:
```
$ kubectl apply -f elasticsearch.yaml
```
- We are going to use an ElasticsearchDashboard instance to deploy kibana. The elasticsearch instance name must be set as `databaseRef.name` field of ElasticsearchDashboard spec. The dashboard must be deployed in the same namespace with elasticsearch.
- Deploy ElasticsearchDashboard:
```
$ kubectl apply -f elasticsearchDashboard.yaml
```
- We are going to deploy Filebeat and Logstash instances in order to collect Logs and then parse,transform, forward to elasticsearch.
- Make sure to set the elasticsearch admin credentials as user and password in Logstash Configmap > Data > logstash.conf file. Set the elasticsearch URL in hosts array as well.
- Make sure to set log paths in Filebeat configmap > data > filebeat.yml file's `filebeat.inputs` field. Set Logstash service URL in the `output.logstash` field.

Get Elasticsearch Admin credentials:
```
$ kubectl get secret -n log-manager es-cluster-elastic-cred -o jsonpath='{.data.username}' | base64 -d

$ kubectl get secret -n log-manager es-cluster-elastic-cred -o jsonpath='{.data.password}' | base64 -d
```

Deploy Logstash:

```
$ kubectl apply -f logstash.yaml
```

Deploy Filebeat:

```
$ kubectl apply -f filebeat.yaml
```
- From kibana Home > Analytics > Discover section find the logs appearing constantly.