# Install KubeDB
- first install the CSI-Snapshotter controller and Longhorn controller
- Install updated kubeDB version

# Deploy Volume snapshot class
```bash
$ kubectl apply -f vs-class.yaml
```

# Deploy archiver database 
```
$ kubectl apply -f demo-pg.yaml
```

```bash

kubectl exec -it -n demo demo-pg-0 -c postgres -- bash
$ psql
# create database test;

# \c

# create table employee(id SERIAL PRIMARY KEY , name varchar, email varchar);

# insert into employee(name, email) values('emon','emon@appscode.com');

# insert into employee(name, email) values('emruz','emruz@appscode.com');

# insert into employee(name, email) values('rakib','rakib@appscode.com');

# insert into employee(name, email) values('alif','alif@appscode.com');

# select pg_switch_wal();

# select now();

# drop table employee;

# select pg_switch_wal();

```

If a volumesnapshot was successfully created then pause the archiver:

```
kubectl patch pg -n demo demo-pg --type="merge" --patch='{"spec":{"archiver":{"fullBackup": {"pause": true}}}}'
```

# Deploy restore database
copy the `select now();` command's output from archiver postgres cluster and put it in `targetTime` and get the volume snapshots with 
`kubectl get volumesnapshot -n demo` and put it in `snapshotName` spec.

```
kubectl apply -f restore-pg.yaml
```

```
kubectl exec -it -n demo restore-pg-0 -c postgres -- bash
psql

postgres# \l
postgres# \c test
select * from employee;

```
you will see all the table rows will be there as we have restore just before the `drop table` command