# KubeDB: Elasticsearch with TLS

## Deploy a Elasticsearch with EnableSSL false

- For this demo, we will use an Elasticsearch instance in combined mode, every node will perform as master, data and ingest.
- If security is enabled in the cluster, the transport layer is always secured with certificate.
- So, if you don't mention the issuer reference at Elasticsearch instance, the operator will create the required certificate with a self signed CA.
- Let's deploy the elasticsearch with enableSSL="false", and transport layer certificate signed with self signed CA.

```
$ kubectl apply -f es-combined.yaml
```

Let's port-forward the client sevice and connect to our cluster:

```
$ kubectl port-forward -n demo svc/es-combined 9200

// Export password
$ export ES_PASSWORD=(kubectl get secret -n demo es-combined-admin-cred -o=jsonpath={.data.password} | base64 -d)

// Check cluster health
// Make sure that the URL start with "http"
$ curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/_cluster/health?pretty"

// Insert some dummy indices 
$ curl -XPUT -u "admin:$ES_PASSWORD"  "http://localhost:9200/demo_index0"
$ curl -XPUT -u "admin:$ES_PASSWORD"  "http://localhost:9200/demo_index1"
$ curl -XPUT -u "admin:$ES_PASSWORD"  "http://localhost:9200/demo_index3"

// List indices
$ curl -XGET -u "admin:$ES_PASSWORD"  "http://localhost:9200/_cat/indices"
```


## Enable Cert-Manager Managed TLS

- We will need a cert-manager Issuer object.

```
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ca.key -out ./ca.crt -subj "/CN=elasticsearch/O=kubedb"

$ kubectl create secret tls es-ca \
       --cert=ca.crt \
       --key=ca.key \
       --namespace=demo

$ kubectl apply -f issuer.yaml

$ kubectl get issuer -n demo
NAME        READY   AGE
es-issuer   True    109m
```