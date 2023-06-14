sudo apt install python-is-python3

sudo sysctl fs.inotify.max_user_instances=65534

clusteradm join --hub-token eyJhbGciOiJSUzI1NiIsImtpZCI6Ijl6alRid1ZGS09LNXJrdHFPNmIyTEZpV0lWLTV3b1hGd1NRUS1qQlRKSXcifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjg2NDYwMjIzLCJpYXQiOjE2ODY0NTY2MjMsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJvcGVuLWNsdXN0ZXItbWFuYWdlbWVudCIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJjbHVzdGVyLWJvb3RzdHJhcCIsInVpZCI6ImM3Mzk3YmRlLWM4NzAtNGExNS05YWRiLWQ0M2I5NDE4OTliMiJ9fSwibmJmIjoxNjg2NDU2NjIzLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6b3Blbi1jbHVzdGVyLW1hbmFnZW1lbnQ6Y2x1c3Rlci1ib290c3RyYXAifQ.h6QHx0FPPJC8MD7tYsFqZNYLplcCLBz2j-PrYy7zgUqIbNyQA1mORfZ4v_FRQBUD61RNppzgI2pBfcFaiJRLV_6sMaCkwpGxBI6paC1CP3Xhs7so3H0D6ez5CtYOsrLobhF9-YUk6wN7A8FWjhGDK6vBmgYxpAStY3Dz_a_cUypJqEf4Zu1e4QX4u4sJkd3w_g4v-fuRBQ1f1sZec0tGZw8NEAD6K4YU4PtRj_ZZJX9JS1l4U3zDpKwC7yUGtQ98BxhkxmPq56cV-MrIARMnEMQwk18p1XFMMsxJAESEZDXhApOOPClFwxhzhbUssWtBujBj2oCWo_rjBwNOUYAltg --hub-apiserver https://127.0.0.1:41371 --wait --cluster-name <cluster_name>


clusteradm get token

## Clustersets

clusteradm create clusterset app1
clusteradm clusterset set app1 --clusters c1

clusteradm create clusterset app2
clusteradm clusterset set app2 --clusters c2

k create ns app1
clusteradm clusterset bind app1 --namespace app1

k create ns app2
clusteradm clusterset bind app2 --namespace app2

> k create ns kubedb
> k create ns kubeops
> clusteradm clusterset bind global --namespace kubedb
> clusteradm clusterset bind global --namespace kubeops

> clusteradm get clustersets
<ManagedClusterSet> 
└── <app2> 
│   ├── <BoundNamespace> app2
│   ├── <Status> 1 ManagedClusters selected
│   ├── <Clusters> [c2]
└── <default> 
│   ├── <BoundNamespace> 
│   ├── <Status> No ManagedCluster selected
│   ├── <Clusters> []
└── <global> 
│   ├── <BoundNamespace> kubedb,kubeops
│   ├── <Status> 2 ManagedClusters selected
│   ├── <Clusters> [c1 c2]
└── <app1> 
    └── <BoundNamespace> app1
    └── <Status> 1 ManagedClusters selected
    └── <Clusters> [c1]
