## Work Environment:

```
kubectl version --short
```

```
kubectl get pods -n kube-system 
```

Deploy Elasticsearch:

```
kubectl apply -f elasticsearch-topology.yaml
```

Wait for the elasticseach to get ready.

- An Elasticsearch node takes aroud 2mins to be initialized

```
$ kubectl port-forward -n demo svc/es-topology 9200

$ curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/_cluster/health?pretty"

```

## Version Upgrade

- Let's list the available version KubeDB supports

```
$ kubectl get esversion
```

Apply the yaml:

```
kubectl apply -f version-upgrade.yaml
```

- Let's check the version from inside:

```bash
$ curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/"
```

- Also check the index that we created:

```bash
$ curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/_cat/indices"
```

## Vertical Scaling

- Here we set both request and limit
- or we can only set the request or limit

- before performing scale operation on elasticsearch, let's check the jvm heap size for each type of nodes.

```
curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/_cat/nodes?h=n,heap*&v"

```

- the heap size the 50% of psysical memory, which is recommended by Elasticsearch
- Now, let's perform the vertical scaling with new resouce configurations

```
kubectl apply -f vertical-scaling.yaml 
```

- let's check new heap size

## Horizontal Scale Up

- apply scale up ops request:

```
kubectl apply -f horizontal-scale-up.yaml 
```

- now check the cluster health, `/_cluster/health?v`
  
- So, here we can see, that all nodes have connected to the cluster


- Let's check the data, `/_cat/shards`
- Here we can see, that all shards is distributed over all data nodes

- Now, let's scale down the nodes
- While performing scale down for data nodes, the operator moves all data from it before performing restart.
- Let's check the data, `/_cat/shards`

## Volume Expansion

Check the available disk:

```
curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/_cat/nodes?h=n,h,diskAvail"
```
Apply the ops request:

```
kubectl apply -f volume-expansion.yaml
```

List the pvcs

```
kubectl get pvc -n demo
```

Check the disk again


Check the data

## Fail Over

- Delete a data pods

- Check the data pods
