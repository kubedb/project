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
$ kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cert-manager.yaml
```

### Generate ca.key and ca.crt
```shell
$ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ca.key -out ./ca.crt -subj "/CN=mysql/O=kubedb"
```

### Create secret with ca.crt and ca.key
```shell
$ kubectl create secret tls my-ca \
      --cert=ca.crt \
      --key=ca.key \
      --namespace=demo
```

### Deploy issuer
```shell
$ kubectl apply -f issuer.yaml
```

### Deploy MySQL
```shell
$ kubectl apply -f mysql.yaml
```

### Deploy ProxySQL
```shell
$ kubectl apply -f proxysql.yaml
```

### Deploy extra pod, install mysql-client, nano and write script for load
```shell
$ kubectl apply -f extraPod.yaml
$ kubectl exec -it -n demo ubuntu-6c6d9795f4-z5cvc  -- bash
root@ubuntu-6c6d9795f4-z5cvc:/# apt-get update && apt-get install -y mysql-client nano
... ... ...

root@ubuntu-6c6d9795f4-z5cvc:/# nano load.sh

#paste the follwing script in the pop-up window
COUNTER=0

USER='test'
PROXYSQL_NAME='proxy-mysql-server'
NAMESPACE='demo'
PASS='test'

VAR="x"

while [  $COUNTER -lt 100 ]; do
    let COUNTER=COUNTER+1
    VAR=a$VAR
    mysql -u$USER -h$PROXYSQL_NAME.$NAMESPACE.svc -P6033 -p$PASS -e 'select 1;' > /dev/null
    mysql -u$USER -h$PROXYSQL_NAME.$NAMESPACE.svc -P6033 -p$PASS -e "INSERT INTO random.randomtb(colma, colmb) VALUES ('$VAR',50);" > /dev/null
    mysql -u$USER -h$PROXYSQL_NAME.$NAMESPACE.svc -P6033 -p$PASS -e "select * from random.randomtb;" > /dev/null
    sleep 0.0001
done
#script ends

root@ubuntu-6c6d9795f4-z5cvc:/# chmod +x load.sh
```

Webinar video [Link](https://youtu.be/oFi37vqCjcw) 
