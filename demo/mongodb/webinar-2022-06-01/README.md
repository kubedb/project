## AppsCode Webinar 01-06-22

<p class="has-text-centered">
  <img src="./static/Arbiter-webinar-poster.png" alt="Poster" style="border: none">
</p>

## Managing MongoDB with Arbiter on Kubernetes using KubeDB


### Install KubeDB
```shell
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
$ helm install kubedb appscode/kubedb \
  --version v2022.05.24 \
  --namespace kubedb --create-namespace \
  --set kubedb-provisioner.enabled=true \
  --set kubedb-ops-manager.enabled=true \
  --set kubedb-autoscaler.enabled=true \
  --set kubedb-dashboard.enabled=true \
  --set kubedb-schema-manager.enabled=true \
  --set-file global.license=/path/to/the/license.txt
```

### Install cert-manager
```shell
$ helm repo add jetstack https://charts.jetstack.io
$ helm repo update

$ helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.8.0 \
  --set installCRDs=true
```

### Generate ca.key and ca.crt
```shell
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ca.key -out ./ca.crt -subj "/CN=mysql/O=kubedb"
```

### Create db namespace
```shell
$ kubectl create ns db
```

### Create secret with ca.crt and ca.key
```shell
$ kubectl create secret tls mongo-ca \
      --cert=ca.crt \
      --key=ca.key \
      --namespace=db
```

### Deploy issuer
```shell
$ kubectl apply -f deploy/issuer.yaml
```

### Deploy MongoDB replica set
```shell
$ kubectl apply -f deploy/replica.yaml
```

### Vertically scale the Pods
```shell
$ kubectl apply -f deploy/vertical.yaml
```

### Create config-secret (used in sharded mongodb)
```shell
$ kubectl create secret generic -n db custom-config --from-file=./deploy/mongod.conf
```

### Deploy Sharded MongoDB with arbiter
```shell
$ kubectl apply -f deploy/shard.yaml
```

### Create config-secret (used in reconfigure ops-request)
```shell
$ kubectl create secret generic -n db log-config --from-file=./deploy/arb-log.conf
```

### Reconfigure the Pods
```shell
$ kubectl apply -f deploy/reconfigure.yaml
```

## Mongo specific commands 
```shell
# On TLS disabled MongoDB
$ mongo -u root -p "$MONGO_INITDB_ROOT_PASSWORD"

# On TLS enabled MongoDB
$ mongo --ipv6 --host localhost --tls --tlsCAFile /var/run/mongodb/tls/ca.crt --tlsCertificateKeyFile /var/run/mongodb/tls/mongo.pem -u root -p "$MONGO_INITDB_ROOT_PASSWORD"

# On Arbiter pods
$ mongo admin

# To enable secondary for running commands into it
$ rs.slaveOk()

# Show the replica-set status
$ rs.status()

# To show db-specific configurations & arguments
$ db._adminCommand({getCmdLineOpts: 1})
```