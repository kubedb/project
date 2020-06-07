# Standardize Secret Keys

A standard Secret format for a particular database is necessary to establish inter-operability. The goal of this KEP is to explore all well known database deployment processes and study their Secret format so that we can chose a Secret format that will give the suers maximum benefits.

## PostgreSQL

| Deploy Process                                                                    | User Key        | Password Key                                                                                                        |
| --------------------------------------------------------------------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------- |
| KubeDB                                                                            | `POSTGRES_USER` | `POSTGRES_PASSWORD`                                                                                                 |
| Official Docker Image                                                             | `POSTGRES_USER` | `POSTGRES_PASSWORD`                                                                                                 |
| `helm/stable` or `bitnami`                                                        |                 | `postgresql-postgres-password`, `postgresql-password`, `postgresql-replication-password`,`postgresql-ldap-password` |
| [CrunchyData/postgres-operator](https://github.com/CrunchyData/postgres-operator) | `username`      | `password`                                                                                                          |
| [zalando/postgres-operator](https://github.com/zalando/postgres-operator/)        |                 | `password`                                                                                                          |

## MySQL

| Deploy Process                                                          | User Key     | Password Key                                                          |
| ----------------------------------------------------------------------- | ------------ | --------------------------------------------------------------------- |
| KubeDB                                                                  | `username`   | `password`                                                            |
| Official Docker Image                                                   | `MYSQL_USER` | `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`                               |
| `helm/stable`                                                           |              | `mysql-root-password`, `mysql-password`                               |
| `bitnami/mysql`                                                         |              | `mysql-root-password`, `mysql-password`, `mysql-replication-password` |
| [oracle/mysql-operator](https://github.com/oracle/mysql-operator)       |              | `password`                                                            |
| [presslabs/mysql-operator](https://github.com/presslabs/mysql-operator) | `USER`       | `ROOT_PASSWORD`, `PASSWORD`                                           |

## Percona-XtraDB

| Deploy Process                                                                                        | User Key   | Password Key                                                            |
| ----------------------------------------------------------------------------------------------------- | ---------- | ----------------------------------------------------------------------- |
| KubeDB                                                                                                | `username` | `password`                                                              |
| `helm/stable`                                                                                         |            | `mysql-root-password`, `mysql-password`, `xtrabackup-password`          |
| [percona/percona-xtradb-cluster-operator](https://github.com/percona/percona-xtradb-cluster-operator) |            | `root`,`xtrabackup`, `monitor`, `clustercheck`,`proxyadmin`,`pmmserver` |


## MongoDB

| Deploy Process                                                                                        | User Key                                                                                                                                         | Password Key                                                                                                                                                        |
| ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| KubeDB                                                                                                | `username`                                                                                                                                       | `password`                                                                                                                                                          |
| Official Docker Image                                                                                 | `MONGO_INITDB_ROOT_USERNAME`                                                                                                                     | `MONGO_INITDB_ROOT_PASSWORD`                                                                                                                                        |
| `helm/stable` or `bitnami`                                                                            |                                                                                                                                                  | `mongodb-root-password`, `mongodb-password`, `mongodb-replica-set-key`                                                                                              |
| [mongodb/mongodb-enterprise-kubernetes](https://github.com/mongodb/mongodb-enterprise-kubernetes)     | `Username`                                                                                                                                       | `Password`                                                                                                                                                          |
| [percona/percona-server-mongodb-operator](https://github.com/percona/percona-server-mongodb-operator) | `MONGODB_BACKUP_USER`,<br> `MONGODB_CLUSTER_ADMIN_USER`,<br> `MONGODB_CLUSTER_MONITOR_USER`,<br> `MONGODB_USER_ADMIN_USER`,<br>`PMM_SERVER_USER` | `MONGODB_BACKUP_PASSWORD`, <br>`MONGODB_CLUSTER_ADMIN_PASSWORD`,<br> `MONGODB_CLUSTER_MONITOR_PASSWORD`,<br>`MONGODB_USER_ADMIN_PASSWORD`,<br>`PMM_SERVER_PASSWORD` |

## Elasticsearch

| Deploy Process                                                  | User Key         | Password Key     |
| --------------------------------------------------------------- | ---------------- | ---------------- |
| KubeDB                                                          | `ADMIN_USERNAME` | `ADMIN_PASSWORD` |
| `helm/stable`                                                   |                  | `auth`           |
| [elastic/cloud-on-k8s](https://github.com/elastic/cloud-on-k8s) |                  | `elastic`        |
