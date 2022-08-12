### Install KubeDB
```shell
$ helm repo add appscode https://charts.appscode.com/stable/
$ helm repo update
$ helm install kubedb appscode/kubedb \
  --version v2022.08.08 \
  --namespace kubedb --create-namespace \
  --set kubedb-provisioner.enabled=true \
  --set kubedb-ops-manager.enabled=true \
  --set kubedb-autoscaler.enabled=true \
  --set kubedb-dashboard.enabled=true \
  --set kubedb-schema-manager.enabled=true \
  --set-file global.license=/path/to/the/license.txt
```

### Deploy MySQL
```shell
$ kubectl apply -f mysql.yaml
```
###Create users in MySQL server
```mysql
mysql> create user 'user1'@'%' identified by 'pass1';
mysql> grant all privileges on *.* to 'user1'@'%';
mysql> create user 'user2'@'%' identified by 'pass2';
mysql> grant all privileges on *.* to 'user2'@'%';
mysql> create user 'A_Add'@'%' identified by 'passA';
mysql> grant all privileges on *.* to 'A_Add'@'%';
mysql> create user 'B_Add'@'%' identified by 'passB';
mysql> grant all privileges on *.* to 'B_Add'@'%';
mysql> create user 'C_Del'@'%' identified by 'passC';
mysql> grant all privileges on *.* to 'C_Del'@'%';
mysql> create user 'D_Del'@'%' identified by 'passD';
mysql> grant all privileges on *.* to 'D_Del'@'%';
mysql> create user 'E_Upd'@'%' identified by 'passE';
mysql> grant all privileges on *.* to 'E_Upd'@'%';
mysql> create user 'F_Upd'@'%' identified by 'passF';
mysql> grant all privileges on *.* to 'F_Upd'@'%';
mysql> flush privileges;
```

###Create custom configuration secret 
```shell
$ kubectl create secret generic my-config-secret \
    --from-file=./MySQLQueryRules.cnf \
    --from-file=./AdminVariables.cnf \
    --namespace=demo
```

### Deploy ProxySQL
```shell
$ kubectl apply -f proxysql.yaml
```

###Reconfigure with Ops-request
```shell
$ kubectl apply -f reconfigUsers.yaml
$ kubectl apply -f reconfigVars.yaml
```

###Scale-up with horizontal scaling
```shell
$ kubectl apply -f scaleUp.yaml
```

###Scale-down with horizontal scaling
```shell
$ kubectl apply -f scaleDown.yaml
```

Webinar video [Link](https://youtu.be/fT_cQDxfU9o) 
